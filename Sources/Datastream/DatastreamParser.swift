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
    
    
    /// Returns a parser for reading a datastream file at the provided URL.
    init(url: URL) {
        self.fileURL = url
    }
    
    /// The datastream file contents, as an asynchronous sequence of `Record`s.
    var records: AsyncRecordSequence {
        return AsyncRecordSequence(url: fileURL)
    }
    
    func parse() async throws -> Datastream {
        recordIterator = records.makeAsyncIterator().peekable()
        
        // These need doing in the order they appear in the datastream file
        let herdDetails = try await parseHerdDetailsSection()
        let recordings = try await parseHerdRecordingsSection()
        let animals = try await parseAnimalDetailsSection()
        let nmrNumber = try await parseNMRNumber()
        let statements = try await parseStatementsSection()
        let lactations = try await parseLactationsSection()
        let bulls = try await parseBullsSection()
        
        return Datastream(herdDetails: herdDetails, recordings: recordings, animals: animals, nmrHerdNumber: nmrNumber, statements: statements, lactations: lactations, bulls: bulls)
    }
}


extension DatastreamParser {
    private func parseHerdDetailsSection() async throws -> HerdDetails {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .nmrDetails,
                     "Iterator must start at H1 to use \(#function)")
        
        var herdDetailsRecords: [RecordDescriptor : Record] = [:]
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            herdDetailsRecords[currentRecord.descriptor] = currentRecord
        } while try await recordIterator!.peek()?.descriptor != .recordingPart1
        
        return try HerdDetails(records: herdDetailsRecords)
    }
    
    private func parseHerdRecordingsSection() async throws -> [HerdRecording] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .recordingPart1,
                     "Iterator must start at HD to use \(#function)")
        
        var recordingRecords = [Record]()
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            recordingRecords.append(currentRecord)
        } while try await recordIterator!.peek()?.descriptor.section == .herd
        
        guard recordingRecords.count % 2 == 0 else {
            throw DatastreamError(code: .malformedInput, recordContent: "Uneven recording record count")
        }
        return stride(from: 0, to: recordingRecords.endIndex, by: 2).map { idx -> HerdRecording in
            let p1 = recordingRecords[idx] as! RecordingPart1
            let p2 = recordingRecords[idx.advanced(by: 1)] as! RecordingPart2
            return HerdRecording(part1: p1, part2: p2)
        }
    }
    
    private func parseAnimalDetailsSection() async throws -> [Animal] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .animalIdentity,
                     "Iterator must start at C1 to use \(#function)")
        
        // Batch up records C1 - C8 then make an animal from them
        var batchAnimalRecords: [RecordDescriptor : Record] = [:]
        var parsedAnimals: [Animal] = []
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            batchAnimalRecords[currentRecord.descriptor] = currentRecord
            
            let peekedItem = try await recordIterator!.peek()
            if peekedItem?.descriptor == .animalIdentity || peekedItem?.descriptor.section != .animal {
                parsedAnimals.append(try Animal(records: batchAnimalRecords))
                batchAnimalRecords = [:]
            }
        } while try await recordIterator!.peek()?.descriptor.section == .animal
        
        return parsedAnimals
    }
    
    private func parseNMRNumber() async throws -> String {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .statementSectionLeader,
                     "Iterator must start at S0 to use \(#function)")
        
        guard let s0 = try await recordIterator?.next() as? StatementHeaderRecord else {
            throw DatastreamError(code: .malformedInput, recordContent: "Missing S0 record.")
        }
        
        return s0.nmrNumber
    }
    
    private func parseStatementsSection() async throws -> [AnimalStatement] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .cowIDRecord,
                     "Iterator must start at S1 to use \(#function)")
        
        // Batch up records S1 - SX then make an animal from them
        var batchedStatementRecords = [Record]()
        var parsedStatements: [AnimalStatement] = []
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            batchedStatementRecords.append(currentRecord)
            
            let peekedItem = try await recordIterator!.peek()
            if peekedItem?.descriptor == .cowIDRecord || peekedItem?.descriptor.section != .statement {
                parsedStatements.append(try AnimalStatement(records: batchedStatementRecords))
                batchedStatementRecords = [Record]()
            }
        } while try await recordIterator!.peek()?.descriptor.section == .statement
        
        return parsedStatements
    }
    
    private func parseLactationsSection() async throws -> [Lactation] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .lactationSectionLeader,
                     "Iterator must start at L0 to use \(#function)")
        let _ = try await recordIterator?.next() // Skip the L0 record
        
        // Batch up records L1 - L5 then make a Lactation from them
        var batchedLactationRecords = [Record]()
        var parsedLactations: [Lactation] = []
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            batchedLactationRecords.append(currentRecord)
            
            let peekedItem = try await recordIterator!.peek()
            if peekedItem?.descriptor == .lactationFixedDetails || peekedItem?.descriptor.section != .lactation {
                parsedLactations.append(try Lactation(records: batchedLactationRecords))
                batchedLactationRecords = [Record]()
            }
        } while try await recordIterator!.peek()?.descriptor.section == .lactation
        
        return parsedLactations
    }
    
    private func parseBullsSection() async throws -> [BullDetails] {
        precondition(recordIterator != nil, "Must have an iterator before calling \(#function)")
        let peekedRecord = try await recordIterator?.peek()
        precondition(peekedRecord?.descriptor == .bullDetails,
                     "Iterator must start at B1 to use \(#function)")
        
        // Batch up records B1 - B7 then make a BullDetails from them
        var batchedBullRecords = [Record]()
        var parsedBulls: [BullDetails] = []
        repeat {
            guard let currentRecord = try await recordIterator!.next() else { break }
            batchedBullRecords.append(currentRecord)
            
            let peekedItem = try await recordIterator!.peek()
            if peekedItem?.descriptor == .bullDetails || peekedItem?.descriptor.section != .bullIdentity {
                parsedBulls.append(try BullDetails(records: batchedBullRecords))
                batchedBullRecords = [Record]()
                print("batched: \(parsedBulls.count)")
            }
        } while try await recordIterator!.peek()?.descriptor.section == .bullIdentity
        
        return parsedBulls
    }
}



// MARK: -
extension HerdDetails {
    fileprivate init(records: [RecordDescriptor : Record]) throws {
        precondition(records[.nmrDetails] != nil, "Missing required record \(RecordDescriptor.nmrDetails)")
        precondition(records[.serviceIndicators] != nil, "Missing required record \(RecordDescriptor.serviceIndicators)")
        precondition(records[.serviceIndicatorsContinued] != nil, "Missing required record \(RecordDescriptor.serviceIndicatorsContinued)")
        
        guard let h1 = records[.nmrDetails] as? NMRDetails,
              let h7 = records[.serviceIndicators] as? ServiceIndicators,
              let h8 = records[.serviceIndicatorsContinued] as? ServiceIndicatorsContinued
              else {
                  throw DatastreamError(code: .malformedInput, recordContent: "Missing required datastream records: H1, H7 or H8")
              }
        let address = records.compactMap({ ($0.value as? TextRecord)?.content })

        let internalRecords = records.filter({ $0.value.descriptor.isPrivateUse }).map({ $0.value as! BaseRecord })
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
                           cellCountMembership: h8.cellCountMembership,
                           internalHerdRecords: internalRecords)
        
        self.init(nationalHerdMark: h1.nationalHerdMark,
                  predominantBreed: h1.predominantBreed,
                        herdPrefix: h1.herdPrefix,
                         enrolDate: h1.enrolDate,
                           address: address,
                            county: h7.county,
                          postcode: h7.postcode,
                    nmrInformation: nmrInfo)
    }
}

extension HerdRecording {
    fileprivate init(part1: RecordingPart1, part2: RecordingPart2) {
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

extension Animal {
    fileprivate init(records: [RecordDescriptor : Record]) throws {
        guard let c1 = records[.animalIdentity] as? AnimalIdentityRecord,
              let c2 = records[.animalOtherDetails] as? AnimalOtherDetailsRecord,
              let c3 = records[.animalName] as? AnimalNameRecord,
              let c4 = records[.animalSireDam] as? AnimalParentsRecord,
              let _ = records[.animalPTA] as? PTARecord
              else {
                  throw DatastreamError(code: .malformedInput, recordContent: "Missing required datastream record. Must have one each of C1 through C5. Optionally up to C8.")
              }
        
        let evaluations = records.values.compactMap({ $0 as? PTARecord }).compactMap({ GeneticEvaluation(record: $0) })
        let dam = AnimalParent(identity: c4.damIdentity,
                           identityType: c4.damIdentityType,
                                  breed: c4.damBreed,
                         pedigreeStatus: c4.damPedigreeStatus,
                   identityAuthenticity: c4.damIdentityAuthenticity)
        let sire = AnimalParent(identity: c4.sireIdentity,
                            identityType: c4.sireIdentityType,
                                   breed: c4.sireBreed,
                          pedigreeStatus: nil,
                    identityAuthenticity: nil)
        self.init(nmrHerdNumber: c1.nmrHerdNumber,
                      aliveFlag: c1.liveFlag,
                     lineNumber: c1.lineNumber,
                        breedID: c1.breedID,
                       identity: c1.identityNumber,
                         idType: c1.identityType,
                 pedigreeStatus: c1.pedigreeStatus,
                hbnAuthenticity: c1.hbnAuthenticity,
           identityAuthenticity: c1.earmarkAuthenticity,
               alternativeBreed: c2.alternativeBreed,
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

extension AnimalStatement {
    fileprivate init(records: [Record]) throws {
        guard let s1 = records.first(typed: CowIDRecord.self),
              let sx = records.first(typed: LactationDetailsRecord.self)
              else {
                  throw DatastreamError(code: .malformedInput, recordContent: "Missing required datastream record. Each animal statement must have at least S1 and SX records.")
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
                       isAuthentic: s4.isAuthentic,
                         sireBreed: s4.sireBreed,
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
                                         calfBreed: s5.calf1Breed,
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
                                         calfBreed: s5.calf2Breed,
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
                                             calfBreed: s6.calfBreed,
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
                                           calfBreed: 0,
                                        calfIdentity: "",
                                    calfIdentityType: .noID,
                            calfIdentityAuthenticity: .nonAuthentic,
                                             calfSex: .dead)
            calvings.append(assumedCalf)
        }
        let otherEvents = records.compactMap({ $0 as? OtherEventRecord }).map { record in
            OtherEvent(eventDate: record.eventDate, eventAuthenticity: record.eventAuthenticity, eventType: record.descriptor)
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
        let sireDetails = SireDetails(sireBreed: s1.sireBreedCode,
                                   sireIdentity: s1.sireIdentity,
                               sireIdentityType: s1.sireIdentityType,
                       sireIdentityAuthenticity: s1.sireIdentityAuthenticity)
        
        self.init(lineNumber: s1.lineNumber,
                   aliveFlag: s1.liveFlag,
                isYoungstock: s1.isYoungstock,
                   breedCode: s1.breedCode,
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

extension Lactation {
    fileprivate init(records: [Record]) throws {
        guard let l1 = records.first(typed: CompletedLactationRecord.self),
              let l2 = records.first(typed: CalvingDetailsRecord.self),
              let l4 = records.first(typed: LactationTotalsRecord.self, withDescriptor: .lactation305dTotals)
              else {
                  throw DatastreamError(code: .malformedInput, recordContent: "Missing required datastream records. Each lactation must have at least L1, L2 and L4 records.")
              }
        
        let sire = SireDetails(sireBreed: l2.sireBreed,
                            sireIdentity: l2.sireIdentity,
                        sireIdentityType: l2.sireIdentityType,
                sireIdentityAuthenticity: l2.sireIdentityAuthenticity)
        
        // It is not guaranteed that any calves will be included
        var calvings = [CalvingEvent]()
        if l2.calfSex != nil {
            let calf1 = CalvingEvent(eventDate: l2.calvingDate,
                             eventAuthenticity: l2.calvingDateAuthenticity,
                                     isAssumed: false,
                                     calfBreed: l2.calfBreed,
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
                                     calfBreed: l3.calf2Breed,
                                  calfIdentity: l3.calf2Identity,
                              calfIdentityType: l3.calf2IdentityType,
                      calfIdentityAuthenticity: l3.calf2IdentityAuthenticity,
                                       calfSex: l3.calf2Sex!)
            calvings.append(calf2)
            
            if l3.calf3Sex != nil {
                let calf3 = CalvingEvent(eventDate: l2.calvingDate,
                                 eventAuthenticity: l2.calvingDateAuthenticity,
                                         isAssumed: false,
                                         calfBreed: l3.calf3Breed,
                                      calfIdentity: l3.calf3Identity,
                                  calfIdentityType: l3.calf3IdentityType,
                          calfIdentityAuthenticity: l3.calf3IdentityAuthenticity,
                                           calfSex: l3.calf3Sex!)
                calvings.append(calf3)
            }
        }
        
        let production305 = LactationProduction(record: l4)
        let productionNatural = records.first(typed: LactationTotalsRecord.self, withDescriptor: .lactationNaturalTotals).map({LactationProduction(record: $0)})
        
        self.init(lineNumber: l1.lineNumber,
                   aliveFlag: l1.aliveFlag,
             lactationNumber: l1.lactationNumber,
    estimatedLactationNumber: l1.estimatedLactationNumber,
                   breedCode: l1.breedCode,
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

extension BullDetails {
    fileprivate init(records: [Record]) throws {
        guard let b1 = records.first(typed: BullDetailsRecord.self) else {
            throw DatastreamError(code: .malformedInput, recordContent: "Missing required datastream records. Bulls must have a B1 record.")
        }
        let evaluations = records.compactMap({ $0 as? PTARecord }).compactMap({ GeneticEvaluation(record: $0) })
        self.init(breed: b1.breed, identity: b1.identity, longName: b1.longName, shortName: b1.shortName, evaluations: evaluations)
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

