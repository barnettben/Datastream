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
        
        return Datastream(herdDetails: herdDetails, recordings: recordings, animals: animals)
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
        
        let evaluations = records.values.compactMap({ $0 as? PTARecord }).map({
            return GeneticEvaluation(evaluationGroup: $0.evaluationGroup,
                                    evaluationSource: $0.evaluationSource,
                                      evaluationDate: $0.evaluationDate,
                                           ptaMilkKG: $0.ptaMilkKG,
                                            ptaFatKG: $0.ptaFatKG,
                                        ptaProteinKG: $0.ptaProteinKG,
                                           ptaFatPct: $0.ptaFatPct,
                                       ptaProteinPct: $0.ptaProteinPct,
                                         reliability: $0.reliability)
        })
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
