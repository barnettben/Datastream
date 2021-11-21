//
//  DatastreamParser.swift
//  
//
//  Created by Ben Barnett on 19/10/2021.
//

import Foundation

/// A parser of Datastream files
///
/// Provides sequential access to records within the file via the ``records`` property
internal class DatastreamParser {
    
    private var fileURL: URL
    private var recordIterator: PeekableIterator<AsyncRecordSequence.AsyncIterator>?
    private var knownBreeds: [Breed] = Breed.knownBreeds
    
    
    /// Returns a parser for reading a datastream file at the provided URL.
    init(url: URL) {
        self.fileURL = url
    }
    
    /// The datastream file contents, as an asynchronous sequence of `Record`s.
    private var records: AsyncRecordSequence {
        return AsyncRecordSequence(url: fileURL)
    }
    
    func parse() async throws -> Datastream {
        recordIterator = records.makeAsyncIterator().peekable()
        precondition(knownBreeds.first(breedCode: 29) != nil)
        
        // All sections need reading in the order they appear in the datastream file
        let herdDetails                   = try await parseHerdDetailsSection()
        let recordings: [HerdRecording]   = try await parseRepeatingSection(startIdentifier: .recordingPart1)
        let animals: [Animal]             = try await parseRepeatingSection(startIdentifier: .animalIdentity)
        let nmrNumber                     = try await parseNMRNumber()
        let statements: [AnimalStatement] = try await parseRepeatingSection(startIdentifier: .cowIDRecord)
        
        // Lactations, bull and dam identities are optional sections and may not appear
        var lactations: [Lactation] = []
        var bulls: [BullDetails] = []
        var dams: [DeadDam] = []
        if try await recordIterator!.peek()?.recordIdentifier.section == .lactation {
            let _                         = try await parseNMRNumber() // Lactation section leader - ignore
            lactations                    = try await parseRepeatingSection(startIdentifier: .lactationFixedDetails)
        }
        if try await recordIterator!.peek()?.recordIdentifier.section == .bullIdentity {
            bulls                         = try await parseRepeatingSection(startIdentifier: .bullDetails)
        }
        if try await recordIterator!.peek()?.recordIdentifier.section == .damIdentity {
            dams                          = try await parseRepeatingSection(startIdentifier: .deadDamDetails)
        }
        
        let weighCalendar                 = try await parseWeighingCalendarSection()
        let breeds: [Breed]               = try await parseBreedsSection()
        
        return Datastream(herdDetails: herdDetails,
                           recordings: recordings,
                              animals: animals,
                        nmrHerdNumber: nmrNumber,
                           statements: statements,
                           lactations: lactations,
                                bulls: bulls,
                             deadDams: dams,
                     weighingCalendar: weighCalendar,
                               breeds: breeds)
    }
}


extension DatastreamParser {
    private func parseHerdDetailsSection() async throws -> HerdDetails {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.recordIdentifier == .nmrDetails, "Iterator must start at H1 to use \(#function)")
        
        var herdDetailsRecords: [Record] = []
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            herdDetailsRecords.append(currentRecord)
        } while try await recordIterator!.peek()?.recordIdentifier != .recordingPart1
        
        return try HerdDetails(records: herdDetailsRecords, context: ParserContext(breeds: knownBreeds))
    }
    
    /// Parses a repeating group of records into a provided type
    ///
    /// Many parts of the datastream file are a repeated groups of the same record.
    /// eg. The Lactation section consists of many groups of (L1-L5). This function
    /// collects those groups and creates an object of type `T` from them.
    private func parseRepeatingSection<T: RecordBatchInitializable>(startIdentifier: RecordIdentifier) async throws -> [T] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.recordIdentifier == startIdentifier, "Iterator must start at \(startIdentifier.rawValue) to parse into \(T.self)")
        
        // Batch up records then make a `T` from them
        var parsedItems: [T] = []
        while let batchedRecords = try await recordIterator!.collect(untilIdentifier: startIdentifier) {
            parsedItems.append(try T(records: batchedRecords, context: ParserContext(breeds: knownBreeds)))
        }
        
        return parsedItems
    }
    
    private func parseNMRNumber() async throws -> String {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        
        guard let s0 = try await recordIterator?.next() as? NMRNumberRecord else {
            throw DatastreamError(code: .malformedInput, message: "Missing leader record S0 or L0.")
        }
        
        return s0.nmrNumber
    }
    
    private func parseWeighingCalendarSection() async throws -> WeighingCalendar {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.recordIdentifier == .weighCalendarLeader, "Iterator must start at W1 to use \(#function)")
        let w1 = try await recordIterator!.next() as! WeighingCalendarLeaderRecord
        var dates = [WeighingDate]()
        var w2Count = 0
        while try await recordIterator?.peek()?.recordIdentifier == .weighCalendarQuarter {
            let currentRecord = try await recordIterator?.next() as! WeighingQuarterRecord
            dates.append(contentsOf: try WeighingDate.datesFromQuarter(currentRecord))
            w2Count += 1
        }
        
        let calendar = WeighingCalendar(startDate: w1.startDate, endDate: w1.endDate, weighingDates: dates)
        
        let w3 = try await recordIterator!.next() as! WeighingCalendarEndRecord
        if w3.numberOfWeighQuarters != w2Count {
            throw DatastreamError(code: .malformedInput, message: "Number of W2 records (\(w2Count)) does not match W3 value (\(w3.numberOfWeighQuarters))")
        }
        
        return calendar
    }
    
    private func parseBreedsSection() async throws -> [Breed] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.recordIdentifier == .breedRecord1, "Iterator must start at W4 to use \(#function)")
        
        // Batch up records then make create/update a breed object
        while let batchedRecords = try await recordIterator!.collect(untilIdentifier: .breedRecord1) {
            let newBreed = try Breed(records: batchedRecords, context: ParserContext(breeds: knownBreeds))
            if let existingBreed = knownBreeds.first(breedCode: newBreed.code) {
                existingBreed.mergeDetails(from: newBreed)
            } else {
                knownBreeds.append(newBreed)
            }
        }
        
        return knownBreeds
    }
}

// MARK: -
extension PeekableIterator where PeekableIterator.Element == Record {
    
    /// Gathers records until a given type is reached or we leave a record section
    fileprivate mutating func collect(untilIdentifier stopIdentifier: RecordIdentifier) async throws -> [Record]? {
        
        // Check we're not jumping out of our section immediately
        let section = stopIdentifier.section
        if try await peek()?.recordIdentifier.section != section {
            return nil
        }
        
        // Batch up records until we reach our stop type
        // or reach end of section, then break and return
        var batchedRecords = [Record]()
        repeat {
            guard let currentRecord = try await next() else { break }
            batchedRecords.append(currentRecord)
            
            let peekedItem = try await peek()
            if peekedItem?.recordIdentifier == stopIdentifier || peekedItem?.recordIdentifier.section != section {
                break
            }
        } while try await peek()?.recordIdentifier.section == section
        return batchedRecords
    }
}



// MARK: -
fileprivate protocol RecordBatchInitializable {
    init(records: [Record], context: ParserContext) throws
}
fileprivate struct ParserContext {
    var breeds: [Breed]
}

extension HerdDetails: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let h1 = records.first(typed: NMRDetails.self),
              let h7 = records.first(typed: ServiceIndicators.self),
              let h8 = records.first(typed: ServiceIndicatorsContinued.self)
              else {
                  throw DatastreamError(code: .malformedInput, message: "Missing required datastream record(s): H1, H7 or H8")
              }
        let address = records.compactMap({ ($0 as? AddressRecord)?.content })
        let nmrInfo = NMRInformation(nmrCounty: h1.nmrCounty,
                                     nmrOffice: h1.nmrOffice,
                               recordingScheme: h1.recordingScheme,
                              weighingSequence: h1.weighingSequence,
                               lastWeighNumber: h1.lastWeighNumber,
                                   serviceType: h7.serviceType,
                              isProgenyTesting: h7.isProgenyTesting,
                         isLifetimeYieldMember: h7.isLifetimeYieldMember,
                                  cowCardCycle: h7.cowCardCycle,
                             calfCropListCycle: h7.calfCropListCycle,
                                   isHerdwatch: h8.isHerdwatchMember,
                           cellCountMembership: h8.cellCountMembership)
        
        self.init(nationalHerdMark: h1.nationalHerdMark,
                  predominantBreed: context.breeds.withCode(h1.predominantBreedCode),
                        herdPrefix: h1.herdPrefix,
                         enrolDate: h1.enrolDate,
                           address: address,
                            county: h7.county,
                          postcode: h7.postcode,
                    nmrInformation: nmrInfo)
    }
}

extension HerdRecording: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let part1 = records.first(typed: RecordingPart1.self),
              let part2 = records.first(typed: RecordingPart2.self) else {
                  throw DatastreamError(code: .malformedInput, message: "Missing required datastream record. HD/HE records must be present in pairs.")
              }
        self.init(recordingDate: part1.recordingDate,
               weighingSequence: part1.weighingSequence,
                   totalAnimals: part1.totalAnimals,
                     cowsInMilk: part1.cowsInMilk,
                   cows3xMilked: part1.cows3xMilked,
                  herdTotalMilk: part1.herdTotalMilk,
                   herdTotalFat: part1.herdTotalFat,
               herdTotalProtein: part1.herdTotalProtein,
               herdTotalLactose: part1.herdTotalLactose,
            yieldDifferenceCode: part1.yieldDifferenceCode,
                 missedWeighing: part1.missedWeighing,
                  printEligible: part1.printEligible,
                      bulkYield: part2.bulkYield,
                     bulkFatPct: part2.bulkFatPct,
                 bulkProteinPct: part2.bulkProteinPct,
                 bulkLactosePct: part2.bulkLactosePct,
             herdProductionBase: part2.herdProductionBase,
                  bulkCellCount: part2.bulkCellCount)
    }
}

extension Animal: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let c1 = records.first(typed: AnimalIdentityRecord.self),
              let c2 = records.first(typed: AnimalOtherDetailsRecord.self),
              let c3 = records.first(typed: AnimalNameRecord.self),
              let c4 = records.first(typed: AnimalParentsRecord.self),
              let _  = records.first(typed: PTARecord.self)
              else {
                  throw DatastreamError(code: .malformedInput, message: "Missing required datastream record. Must have one each of C1 through C5.")
              }
        
        let evaluations = records.compactMap({ $0 as? PTARecord }).compactMap({ GeneticEvaluation(record: $0) })
        let dam = AnimalParent(identity: c4.damIdentity,
                           identityType: c4.damIdentityType,
                                  breed: context.breeds.withCode(c4.damBreedCode),
                         pedigreeStatus: c4.damPedigreeStatus,
                   identityAuthenticity: c4.damIdentityAuthenticity)
        let sire = AnimalParent(identity: c4.sireIdentity,
                            identityType: c4.sireIdentityType,
                                   breed: context.breeds.withCode(c4.sireBreedCode),
                          pedigreeStatus: nil,
                    identityAuthenticity: nil)
        self.init(nmrHerdNumber: c1.nmrHerdNumber,
                       isInHerd: (c1.liveFlag == "0") ? true : false,
                     lineNumber: c1.lineNumber,
                          breed: context.breeds.withCode(c1.breedCode),
                       identity: c1.identityNumber,
                   identityType: c1.identityType,
                 pedigreeStatus: c1.pedigreeStatus,
                hbnAuthenticity: c1.hbnAuthenticity,
           identityAuthenticity: c1.earmarkAuthenticity,
               alternativeBreed: context.breeds.withCode(c2.alternativeBreedCode),
                  alternativeID: c2.alternativeIdentity,
                      birthDate: c2.birthDate,
                   isYoungstock: c2.isYoungstock,
                  herdEntryDate: c2.entryDate,
                   herdExitDate: c2.exitDate,
                  leavingReason: c2.leavingReason,
                classChangeDate: c2.classChangeDate,
                      shortName: c3.shortName,
                       longName: c3.longName,
                            dam: dam,
                           sire: sire,
                    evaluations: evaluations)
    }
}

extension AnimalStatement: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let s1 = records.first(typed: CowIDRecord.self),
              let sx = records.first(typed: LactationDetailsRecord.self)
              else {
                  throw DatastreamError(code: .malformedInput, message: "Missing required datastream record. Each animal statement must have at least S1 and SX records.")
              }
        let weighings = records.compactMap({ $0 as? WeighingRecord }).map { s3 in
            WeighingEvent(recordingDate: s3.recordingDate,
                             resultType: s3.resultType,
                            timesMilked: s3.timesMilked,
                          absenceReason: s3.absenceReason,
                              milkYield: s3.milkYield,
                                 fatPct: s3.fatPct,
                             proteinPct: s3.proteinPct,
                             lactosePct: s3.lactosePct,
                              cellCount: s3.cellCount)
        }
        let services = records.compactMap({ $0 as? ServiceRecord }).map { s4 in
            ServiceEvent(eventDate: s4.eventDate,
                  evenAuthenticity: s4.eventAuthenticity,
                         sireBreed: context.breeds.withCode(s4.sireBreedCode),
                      sireIdentity: s4.sireIdentity,
          sireIdentityAuthenticity: s4.sireIdentityAuthenticity,
                   pregnancyStatus: s4.pregnancyStatus)
        }
        
        var calvings = [CalvingEvent]()
        if let s5 = records.first(typed: ActualCalvingRecord.self) {
            if s5.calf1Sex != nil {
                let calf1 = CalvingEvent(eventDate: s5.eventDate,
                                 eventAuthenticity: s5.eventAuthenticity,
                                         isAssumed: false,
                                         calfBreed: context.breeds.withCode(s5.calf1BreedCode),
                                      calfIdentity: s5.calf1Identity,
                                  calfIdentityType: s5.calf1IdentityType,
                          calfIdentityAuthenticity: s5.calf1IdentityAuthenticity,
                                           calfSex: s5.calf1Sex!)
                calvings.append(calf1)
            }
            if s5.calf2Sex != nil {
                let calf2 = CalvingEvent(eventDate: s5.eventDate,
                                 eventAuthenticity: s5.eventAuthenticity,
                                         isAssumed: false,
                                         calfBreed: context.breeds.withCode(s5.calf2BreedCode),
                                      calfIdentity: s5.calf2Identity,
                                  calfIdentityType: s5.calf2IdentityType,
                          calfIdentityAuthenticity: s5.calf2IdentityAuthenticity,
                                           calfSex: s5.calf2Sex!)
                calvings.append(calf2)
            }
            // Do this inside if-let-s5 so we have access to s5 for the third calf
            if let s6 = records.first(typed: ActualThirdCalfRecord.self) {
                if s6.calfSex != nil {
                    let calf3 = CalvingEvent(eventDate: s5.eventDate,
                                     eventAuthenticity: s5.eventAuthenticity,
                                             isAssumed: false,
                                             calfBreed: context.breeds.withCode(s6.calfBreedCode),
                                          calfIdentity: s6.calfIdentity,
                                      calfIdentityType: s6.calfIdentityType,
                              calfIdentityAuthenticity: s6.calfIdentityAuthenticity,
                                               calfSex: s6.calfSex!)
                    calvings.append(calf3)
                }
            }
        }
        if let s7 = records.first(typed: AssumedCalvingRecord.self) {
            let assumedCalf = CalvingEvent(eventDate: s7.eventDate,
                                   eventAuthenticity: .nonAuthentic,
                                           isAssumed: true,
                                           calfBreed: context.breeds.withCode(29),
                                        calfIdentity: "",
                                    calfIdentityType: .noID,
                            calfIdentityAuthenticity: .nonAuthentic,
                                             calfSex: .dead)
            calvings.append(assumedCalf)
        }
        let otherEvents = records.compactMap({ $0 as? OtherEventRecord }).map { record in
            OtherEvent(eventDate: record.eventDate, eventAuthenticity: record.eventAuthenticity, eventType: record.recordIdentifier)
        }
        let lactationDetails = LactationDetails(totalDays: sx.totalDays,
                                                totalMilk: sx.totalMilk,
                                                 totalFat: sx.totalFat,
                                             totalProtein: sx.totalProtein,
                                             totalLactose: sx.totalLactose,
                                                   fatPct: sx.fatPct,
                                               proteinPct: sx.proteinPct,
                                               lactosePct: sx.lactosePct,
                                               totalValue: sx.totalValue,
                                     averagePencePerLitre: sx.averagePencePerLitre,
                                              seasonality: sx.seasonality,
                                         averageCellCount: sx.averageCellCount)
        let sireDetails = SireDetails(sireBreed: context.breeds.withCode(s1.sireBreedCode),
                                   sireIdentity: s1.sireIdentity,
                               sireIdentityType: s1.sireIdentityType,
                       sireIdentityAuthenticity: s1.sireIdentityAuthenticity)
        
        self.init(lineNumber: s1.lineNumber,
                    isInHerd: (s1.liveFlag == "0") ? true : false,
                isYoungstock: s1.isYoungstock,
                       breed: context.breeds.withCode(s1.breedCode),
             lactationNumber: s1.lactationNumber,
    estimatedLactationNumber: s1.estimatedLactationNumber,
             managementGroup: s1.group,
              lactationStage: s1.lactationStage,
         previousCalvingDate: s1.lastCalvingDate,
                 sireDetails: sireDetails,
                     dryDays: s1.dryDays,
                   weighings: weighings,
                    services: services,
                    calvings: calvings,
                 otherEvents: otherEvents,
            lactationDetails: lactationDetails)
    }
}

extension Lactation: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let l1 = records.first(typed: CompletedLactationRecord.self),
              let l2 = records.first(typed: CalvingDetailsRecord.self),
              let l4 = records.first(typed: LactationTotalsRecord.self, identifiedBy: .lactation305dTotals)
              else {
                  throw DatastreamError(code: .malformedInput, message: "Missing required datastream records. Each lactation must have at least L1, L2 and L4 records.")
              }
        
        let sire = SireDetails(sireBreed: context.breeds.withCode(l2.sireBreedCode),
                            sireIdentity: l2.sireIdentity,
                        sireIdentityType: l2.sireIdentityType,
                sireIdentityAuthenticity: l2.sireIdentityAuthenticity)
        
        // It is not guaranteed that any calves will be included
        var calvings = [CalvingEvent]()
        if l2.calfSex != nil {
            let calf1 = CalvingEvent(eventDate: l2.calvingDate,
                             eventAuthenticity: l2.calvingDateAuthenticity,
                                     isAssumed: false,
                                     calfBreed: context.breeds.withCode(l2.calfBreedCode),
                                  calfIdentity: l2.calfIdentity,
                              calfIdentityType: l2.calfIdentityType,
                      calfIdentityAuthenticity: l2.calfIdentityAuthenticity,
                                       calfSex: l2.calfSex!)
            calvings.append(calf1)
        }
        
        if let l3 = records.first(typed: CalvingExtraCalvesRecord.self) {
            let calf2 = CalvingEvent(eventDate: l2.calvingDate,
                             eventAuthenticity: l2.calvingDateAuthenticity,
                                     isAssumed: false,
                                     calfBreed: context.breeds.withCode(l3.calf2BreedCode),
                                  calfIdentity: l3.calf2Identity,
                              calfIdentityType: l3.calf2IdentityType,
                      calfIdentityAuthenticity: l3.calf2IdentityAuthenticity,
                                       calfSex: l3.calf2Sex!)
            calvings.append(calf2)
            
            if l3.calf3Sex != nil {
                let calf3 = CalvingEvent(eventDate: l2.calvingDate,
                                 eventAuthenticity: l2.calvingDateAuthenticity,
                                         isAssumed: false,
                                         calfBreed: context.breeds.withCode(l3.calf3BreedCode),
                                      calfIdentity: l3.calf3Identity,
                                  calfIdentityType: l3.calf3IdentityType,
                          calfIdentityAuthenticity: l3.calf3IdentityAuthenticity,
                                           calfSex: l3.calf3Sex!)
                calvings.append(calf3)
            }
        }
        
        let production305 = LactationProduction(record: l4)
        let productionNatural = records.first(typed: LactationTotalsRecord.self, identifiedBy: .lactationNaturalTotals).map({LactationProduction(record: $0)})
        
        self.init(lineNumber: l1.lineNumber,
                    isInHerd: (l1.liveFlag == "0") ? true : false,
             lactationNumber: l1.lactationNumber,
    estimatedLactationNumber: l1.estimatedLactationNumber,
                       breed: context.breeds.withCode(l1.breedCode),
             totalMaleCalves: l1.totalMaleCalves,
           totalFemaleCalves: l1.totalFemaleCalves,
             totalDeadCalves: l1.totalDeadCalves,
             numberOfDryDays: l1.numberOfDryDays,
            numberOfServices: l1.numberOfServices,
            missedRecordings: l1.missedRecordings,
       seasonalityAdjustment: l1.seasonalityAdjustment,
              financialValue: l1.financialValue,
             productionIndex: l1.productionIndex,
              productionBase: l1.productionBase,
           numberOfTimesLame: l1.numberOfTimesLame,
       numberOfTimesMastitis: l1.numberOfTimesMastitis,
           numberOfTimesSick: l1.numberOfTimesSick,
             calvingInterval: l2.calvingInterval,
                ageAtCalving: l2.ageAtCalving,
                 calvingDate: l2.calvingDate,
     calvingDateAuthenticity: l2.calvingDateAuthenticity,
                 sireDetails: sire,
                      calves: calvings,
               production305: production305,
           productionNatural: productionNatural)
    }
}

extension LactationProduction {
    fileprivate init(record: LactationTotalsRecord) {
        self.init(isQualifiedForPublication: record.isQualifiedForPublication,
                          totalAuthenticity: record.totalAuthenticity,
                                  milkYield: record.milkYield,
                                   fatYield: record.fatYield,
                               proteinYield: record.proteinYield,
                               lactoseYield: record.lactoseYield,
                                  totalDays: record.totalDays,
                                total3xDays: record.total3xDays,
                                  startOf3x: record.startOf3x,
                           lactationEndDate: record.lactationEndDate,
                         lactationEndReason: record.lactationEndReason,
                         numberOfRecordings: record.numberOfRecordings,
                           averageCellCount: record.averageCellCount,
                               cellsOver200: record.cellsOver200)
    }
}

extension BullDetails: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let b1 = records.first(typed: BullDetailsRecord.self) else {
            throw DatastreamError(code: .malformedInput, message: "Missing required datastream records. Bulls must have a B1 record.")
        }
        let evaluations = records.compactMap({ $0 as? PTARecord }).compactMap({ GeneticEvaluation(record: $0) })
        self.init(breed: context.breeds.withCode(b1.breedCode), identity: b1.identity, longName: b1.longName, shortName: b1.shortName, evaluations: evaluations)
    }
}

extension DeadDam: RecordBatchInitializable {
    fileprivate init(records: [Record], context: ParserContext) throws {
        guard let d1 = records.first(typed: DeadDamRecord.self) else {
            throw DatastreamError(code: .malformedInput, message: "Missing required datastream records. Dead dams must have a D1 record.")
        }
        let evaluations = records.compactMap({ $0 as? PTARecord }).compactMap({ GeneticEvaluation(record: $0) })
        self.init(identity: d1.identity, identityType: d1.identityType, identityAuthenticity: d1.identityAuthenticity, breed: context.breeds.withCode(d1.breedCode), pedigreeStatus: d1.pedigreeStatus, name: d1.longName, evaluations: evaluations)
    }
}

extension Breed: RecordBatchInitializable {
    fileprivate convenience init(records: [Record], context: ParserContext) throws {
        guard let w4 = records.first(typed: BreedPart1Record.self),
              let w5 = records.first(typed: BreedPart2Record.self),
              let w6 = records.first(typed: BreedPart3Record.self) else {
            throw DatastreamError(code: .malformedInput, message: "Missing required datastream records. Breeds must have W4, W5 and W6 records.")
        }
        print(w4.abbreviation)
        self.init(code: w4.code,
            equivalent: context.breeds.withCode(w4.equivalent),
                  name: w4.name,
          abbreviation: w4.abbreviation,
       gestationPeriod: w4.gestationPeriod,
                  type: .unspecified,
            isImported: false,
         minDailyYield: w4.minDailyYield,
         maxDailyYield: w4.maxDailyYield,
          lowMilkQuery: w4.lowMilkQuery,
         highMilkQuery: w4.highMilkQuery,
             minFatPct: w5.minFatPct,
             maxFatPct: w5.maxFatPct,
           lowFatQuery: w5.lowFatQuery,
          highFatQuery: w5.highFatQuery,
         minProteinPct: w5.minProteinPct,
         maxProteinPct: w5.maxProteinPct,
       lowProteinQuery: w5.lowProteinQuery,
      highProteinQuery: w5.highProteinQuery,
         minLactosePct: w5.minLactosePct,
         maxLactosePct: w5.maxLactosePct,
       lowLactoseQuery: w5.lowLactoseQuery,
      highLactoseQuery: w5.highLactoseQuery,
    high305dYieldQuery: w6.high305dYieldQuery,
 highNaturalYieldQuery: w6.highNaturalYieldQuery,
          max305dYield: w6.max305dYield,
       maxNaturalYield: w6.maxNaturalYield)
    }
}

extension GeneticEvaluation {
    fileprivate init?(record: PTARecord) {
        guard record.evaluationDate != nil else {
            return nil
        }
        self.init(evaluationGroup: record.evaluationGroup,
                 evaluationSource: record.evaluationSource,
                   evaluationDate: record.evaluationDate!,
                        ptaMilkKG: record.ptaMilkKG,
                         ptaFatKG: record.ptaFatKG,
                     ptaProteinKG: record.ptaProteinKG,
                        ptaFatPct: record.ptaFatPct,
                    ptaProteinPct: record.ptaProteinPct,
                      reliability: record.reliability)
   }
}

extension WeighingDate {
    fileprivate static func datesFromQuarter(_ quarter: WeighingQuarterRecord) throws -> [WeighingDate] {
        let m1 = WeighingDate(recordingYear: quarter.year1,
                                   sequence: quarter.sequence1,
                              sequenceMonth: quarter.weighMonth1,
                              calendarMonth: quarter.calendarMonth1,
                              pmWeighingDay: quarter.pmDay1,
                              amWeighingDay: quarter.amDay1)
        let m2 = WeighingDate(recordingYear: quarter.year2,
                                   sequence: quarter.sequence2,
                              sequenceMonth: quarter.weighMonth2,
                              calendarMonth: quarter.calendarMonth2,
                              pmWeighingDay: quarter.pmDay2,
                              amWeighingDay: quarter.amDay2)
        let m3 = WeighingDate(recordingYear: quarter.year3,
                                   sequence: quarter.sequence3,
                              sequenceMonth: quarter.weighMonth3,
                              calendarMonth: quarter.calendarMonth3,
                              pmWeighingDay: quarter.pmDay3,
                              amWeighingDay: quarter.amDay3)
        return [m1, m2, m3]
    }
}

extension Array where Element == Breed {
    
    /// Returns the breed with a given code, or the unknown breed if not found
    public func withCode(_ code: Int) -> Breed {
        if let breed = first(where: { $0.code == code }) {
            return breed
        }
        return first(where: { $0.code == 29 })!
    }
}
