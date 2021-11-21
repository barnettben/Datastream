//
//  Breed+Additions.swift
//  
//
//  Created by Ben Barnett on 21/11/2021.
//

import Foundation

extension Breed {
    
    convenience init(code: Int, gestation: Int, type: BreedType, isImported: Bool, name: String) {
        self.init(code: code, equivalent: 0, name: "", abbreviation: "", gestationPeriod: gestation, type: type, isImported: isImported, minDailyYield: 0, maxDailyYield: 0, lowMilkQuery: 0, highMilkQuery: 0, minFatPct: 0, maxFatPct: 0, lowFatQuery: 0, highFatQuery: 0, minProteinPct: 0, maxProteinPct: 0, lowProteinQuery: 0, highProteinQuery: 0, minLactosePct: 0, maxLactosePct: 0, lowLactoseQuery: 0, highLactoseQuery: 0, high305dYieldQuery: 0, highNaturalYieldQuery: 0, max305dYield: 0, maxNaturalYield: 0)
    }
    
    func mergeDetails(from otherBreed: Breed) {
        equivalent = otherBreed.equivalent
        abbreviation = otherBreed.abbreviation
        gestationPeriod = otherBreed.gestationPeriod
        minDailyYield = otherBreed.minDailyYield
        maxDailyYield = otherBreed.maxDailyYield
        lowMilkQuery = otherBreed.lowMilkQuery
        highMilkQuery = otherBreed.highMilkQuery
        minFatPct = otherBreed.minFatPct
        maxFatPct = otherBreed.maxFatPct
        lowFatQuery = otherBreed.lowFatQuery
        highFatQuery = otherBreed.highFatQuery
        minProteinPct = otherBreed.minProteinPct
        maxProteinPct = otherBreed.maxProteinPct
        lowProteinQuery = otherBreed.lowProteinQuery
        highProteinQuery = otherBreed.highProteinQuery
        minLactosePct = otherBreed.minLactosePct
        maxLactosePct = otherBreed.maxLactosePct
        lowLactoseQuery = otherBreed.lowLactoseQuery
        highLactoseQuery = otherBreed.highLactoseQuery
        high305dYieldQuery = otherBreed.high305dYieldQuery
        highNaturalYieldQuery = otherBreed.highNaturalYieldQuery
        max305dYield = otherBreed.max305dYield
        maxNaturalYield = otherBreed.maxNaturalYield
    }
    
    /// Returns an array of known NMR breed details
    ///
    /// These are from the datastream spec and unlikely to change.
    /// The spec doesn't contain the same information as a datastream file. It has breed purpose and import status
    /// which are not in the file, but other info is not present. This array contains only the basics which can be fleshed out
    /// during parsing or used as-is if required.
    static var knownBreeds: [Breed] {
        return [
            Breed(code: 01, gestation: 280, type: .dairy, isImported: false, name: "Holstein-Friesian (UK&E)"),
            Breed(code: 02, gestation: 280, type: .dairy, isImported: false, name: "Dairy Shorthorn (UK)"),
            Breed(code: 03, gestation: 280, type: .dairy, isImported: false, name: "Ayrshire"),
            Breed(code: 04, gestation: 280, type: .dairy, isImported: false, name: "Jersey (Mainland)"),
            Breed(code: 05, gestation: 280, type: .dairy, isImported: false, name: "Guernsey (Mainland)"),
            Breed(code: 06, gestation: 285, type: .beef, isImported: false, name: "South Devon"),
            Breed(code: 07, gestation: 280, type: .dairy, isImported: false, name: "Red Poll"),
            Breed(code: 08, gestation: 280, type: .beef, isImported: false, name: "Welsh Black"),
            Breed(code: 09, gestation: 280, type: .beef, isImported: false, name: "Lincoln Red"),
            Breed(code: 10, gestation: 280, type: .dairy, isImported: false, name: "Kerry"),
            Breed(code: 11, gestation: 280, type: .dualPurpose, isImported: false, name: "Ancient White Cattle"),
            Breed(code: 12, gestation: 280, type: .dairy, isImported: false, name: "British Holstein"),
            Breed(code: 13, gestation: 280, type: .dairy, isImported: true, name: "NZ/Aus Shorthorn"),
            Breed(code: 14, gestation: 280, type: .dairy, isImported: false, name: "Dexter & Glamorgan"),
            Breed(code: 15, gestation: 280, type: .dairy, isImported: false, name: "Red & White Friesian"),
            Breed(code: 16, gestation: 285, type: .beef, isImported: false, name: "Devon"),
            Breed(code: 17, gestation: 280, type: .dairy, isImported: false, name: "Danish Red"),
            Breed(code: 18, gestation: 285, type: .beef, isImported: false, name: "Charolais"),
            Breed(code: 19, gestation: 283, type: .beef, isImported: false, name: "Hereford"),
            Breed(code: 20, gestation: 280, type: .dairy, isImported: false, name: "Polled Friesian"),
            Breed(code: 21, gestation: 280, type: .beef, isImported: false, name: "Aberdeen Angus"),
            Breed(code: 22, gestation: 280, type: .dairy, isImported: false, name: "British Dane"),
            Breed(code: 23, gestation: 286, type: .beef, isImported: false, name: "Simmental"),
            Breed(code: 24, gestation: 286, type: .dualPurpose, isImported: false, name: "Meuse-Rhine-Issel"),
            Breed(code: 25, gestation: 285, type: .beef, isImported: false, name: "Blonde D'Aquitaine"),
            Breed(code: 26, gestation: 280, type: .dualPurpose, isImported: false, name: "Maine Anjou"),
            Breed(code: 27, gestation: 280, type: .dualPurpose, isImported: false, name: "Minor Breeds/Other"),
            Breed(code: 28, gestation: 280, type: .dairy, isImported: false, name: "Montbeliarde"),
            Breed(code: 29, gestation: 280, type: .dualPurpose, isImported: false, name: "Unknown Breed"),
            Breed(code: 30, gestation: 280, type: .dairy, isImported: false, name: "Gloucester"),
            Breed(code: 31, gestation: 285, type: .dairy, isImported: false, name: "Brown Swiss"),
            Breed(code: 32, gestation: 285, type: .beef, isImported: false, name: "Sussex"),
            Breed(code: 33, gestation: 288, type: .beef, isImported: false, name: "Limousin"),
            Breed(code: 34, gestation: 285, type: .beef, isImported: false, name: "Murray Grey"),
            Breed(code: 35, gestation: 285, type: .beef, isImported: false, name: "Gelbvieh"),
            Breed(code: 36, gestation: 284, type: .dairy, isImported: false, name: "Normande"),
            Breed(code: 37, gestation: 280, type: .beef, isImported: false, name: "Belgian Blue"),
            Breed(code: 38, gestation: 280, type: .beef, isImported: false, name: "Beef Shorthorn"),
            Breed(code: 39, gestation: 286, type: .beef, isImported: false, name: "Chianina"),
            Breed(code: 40, gestation: 280, type: .dairy, isImported: true, name: "European Shorthorn"),
            Breed(code: 41, gestation: 280, type: .beef, isImported: false, name: "Longhorn"),
            Breed(code: 42, gestation: 311, type: .dairy, isImported: false, name: "Water Buffalo"),
            Breed(code: 43, gestation: 285, type: .beef, isImported: false, name: "Marchigiana"),
            Breed(code: 44, gestation: 285, type: .beef, isImported: false, name: "Romagnola"),
            Breed(code: 45, gestation: 280, type: .beef, isImported: false, name: "Galloway"),
            Breed(code: 46, gestation: 285, type: .dairy, isImported: false, name: "Irish Holstein-Friesian"),
            Breed(code: 47, gestation: 280, type: .dairy, isImported: true, name: "Australian Holstein-Friesian"),
            Breed(code: 48, gestation: 280, type: .dairy, isImported: true, name: "Polish Holstein-Friesian"),
            Breed(code: 49, gestation: 280, type: .dairy, isImported: false, name: "Angler"),
            Breed(code: 50, gestation: 280, type: .dairy, isImported: false, name: "Shetland"),
            Breed(code: 51, gestation: 280, type: .dualPurpose, isImported: false, name: "Blue Albion"),
            Breed(code: 52, gestation: 280, type: .dairy, isImported: true, name: "Swedish Holstein-Friesian"),
            Breed(code: 53, gestation: 285, type: .dualPurpose, isImported: false, name: "Rotbunte"),
            Breed(code: 54, gestation: 285, type: .dairy, isImported: false, name: "Spanish Holstein-Friesian"),
            Breed(code: 55, gestation: 285, type: .beef, isImported: false, name: "Piemontese"),
            Breed(code: 56, gestation: 280, type: .beef, isImported: false, name: "Salers"),
            Breed(code: 57, gestation: 280, type: .beef, isImported: false, name: "Highland/Luing"),
            Breed(code: 58, gestation: 280, type: .dairy, isImported: false, name: "Irish Moiled"),
            Breed(code: 59, gestation: 280, type: .dairy, isImported: true, name: "Swedish Red"),
            Breed(code: 60, gestation: 280, type: .dairy, isImported: true, name: "German Holstein-Friesian"),
            Breed(code: 61, gestation: 280, type: .dairy, isImported: true, name: "Danish Holstein-Friesian"),
            Breed(code: 62, gestation: 280, type: .dairy, isImported: true, name: "New Zealand Holstein-Friesian"),
            Breed(code: 63, gestation: 280, type: .dairy, isImported: true, name: "Dutch Holstein-Friesian"),
            Breed(code: 64, gestation: 280, type: .dairy, isImported: true, name: "Canadian Holstein-Friesian"),
            Breed(code: 65, gestation: 280, type: .dairy, isImported: true, name: "American Holstein-Friesian"),
            Breed(code: 66, gestation: 280, type: .dairy, isImported: true, name: "European Jersey"),
            Breed(code: 67, gestation: 280, type: .dairy, isImported: true, name: "North American Guernsey"),
            Breed(code: 68, gestation: 280, type: .dairy, isImported: true, name: "New Zealand/Australian Jersey"),
            Breed(code: 69, gestation: 280, type: .dairy, isImported: true, name: "North American Shorthorn"),
            Breed(code: 70, gestation: 280, type: .dairy, isImported: true, name: "North American Ayrshire"),
            Breed(code: 71, gestation: 280, type: .dairy, isImported: true, name: "French Holstein-Friesian"),
            Breed(code: 72, gestation: 280, type: .dairy, isImported: true, name: "Italian Holstein-Friesian"),
            Breed(code: 73, gestation: 280, type: .dairy, isImported: true, name: "Finnish Ayrshire"),
            Breed(code: 74, gestation: 280, type: .dairy, isImported: true, name: "Island Jersey"),
            Breed(code: 75, gestation: 280, type: .dairy, isImported: true, name: "Island Guernsey"),
            Breed(code: 76, gestation: 280, type: .dairy, isImported: true, name: "North American Jersey"),
            Breed(code: 77, gestation: 280, type: .dairy, isImported: true, name: "Norwegian Red/Ayrshire"),
            Breed(code: 78, gestation: 280, type: .dairy, isImported: true, name: "New Zealand/Australian Ayrshire"),
            Breed(code: 79, gestation: 280, type: .dairy, isImported: true, name: "New Zealand/Australian Guernsey"),
            
            // Goats
            Breed(code: 80, gestation: 149, type: .dairy, isImported: false, name: "BGS Herd Book"),
            Breed(code: 81, gestation: 149, type: .dairy, isImported: false, name: "Anglo Nubian"),
            Breed(code: 82, gestation: 149, type: .dairy, isImported: false, name: "Saanen"),
            Breed(code: 83, gestation: 149, type: .dairy, isImported: false, name: "Toggenburg"),
            Breed(code: 84, gestation: 149, type: .dairy, isImported: false, name: "British Alpine"),
            Breed(code: 85, gestation: 149, type: .dairy, isImported: false, name: "British Saanen"),
            Breed(code: 86, gestation: 149, type: .dairy, isImported: false, name: "British Toggenburg"),
            Breed(code: 87, gestation: 149, type: .dairy, isImported: false, name: "Golden Guernsey"),
            Breed(code: 88, gestation: 149, type: .dairy, isImported: false, name: "English Guernsey"),
            Breed(code: 89, gestation: 149, type: .dairy, isImported: false, name: "Other Breeds (goats)"),
            Breed(code: 90, gestation: 149, type: .dairy, isImported: false, name: "BGS Foundation Book"),
            Breed(code: 91, gestation: 149, type: .dairy, isImported: false, name: "Goats (LP305)"),
            Breed(code: 92, gestation: 149, type: .dairy, isImported: false, name: "BGS Identity Register G"),
            Breed(code: 93, gestation: 149, type: .dairy, isImported: false, name: "BGS Supplementary Register"),
            //Breed(code: 94, <- there is no code 94
            
            // Sheep
            Breed(code: 95, gestation: 147, type: .dairy, isImported: false, name: "Milksheep"),
            Breed(code: 96, gestation: 147, type: .dairy, isImported: false, name: "Friesland"),
            Breed(code: 97, gestation: 147, type: .dairy, isImported: false, name: "Oldenberg"),
            Breed(code: 98, gestation: 147, type: .dairy, isImported: false, name: "Dorset"),
            Breed(code: 99, gestation: 147, type: .dairy, isImported: false, name: "Other Breeds (sheep)"),
        ]
    }
}
