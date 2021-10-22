//
//  Record-HerdDetailsSection.swift
//  
//
//  Created by Ben Barnett on 21/10/2021.
//

import Foundation

struct NMRDetails: Record {
    var descriptor: RecordDescriptor
    var checksum: Int
    var checksumIsValid: Bool

    var nmrCounty: Int
    var nmrOffice: Int
    var recordingScheme: RecordingScheme
    var weighingSequence: Int
    var lastWeighNumber: Int
    var nationalHerdMark: String
    var predominantBreed: Int
    var herdPrefix: String
    var enrolDate: Date

    init(string content: String) throws {
        descriptor = try RecordConstants.descriptorField.extractValue(from: content)
        guard descriptor == .header1 else {
            fatalError("Attempting to create NMRDetails with wrong record type: \(descriptor)")
        }
        checksum = try RecordConstants.checksumField.extractValue(from: content)
        checksumIsValid = NMRDetails.validateRecordStringChecksum(content)

        self.nmrCounty = try Field(location: 3, length: 2).extractValue(from: content)
        self.nmrOffice = try Field(location: 6, length: 2).extractValue(from: content)
        self.recordingScheme = try Field(location: 9, length: 2).extractValue(from: content)
        self.weighingSequence = try Field(location: 12, length: 2).extractValue(from: content)
        self.lastWeighNumber = try Field(location: 15, length: 2).extractValue(from: content)
        self.nationalHerdMark = try Field(location: 33, length: 5).extractValue(from: content)
        self.predominantBreed = try Field(location: 39, length: 2).extractValue(from: content)
        self.herdPrefix = try Field(location: 42, length: 20).extractValue(from: content)
        self.enrolDate = try Field(location: 63, length: 6).extractValue(from: content)
    }
}

