//
//  Average_in_TimePeriod.swift
//  Novalgea
//
//  Created by aDev on 12/03/2024.
//

import Foundation

/// returns Dictionary String:Double for rating category average in time period
struct Average_In_TimePeriod: Identifiable {
    var start: Date
    var end: Date
    var average: Double?
    var ratingsCount: Int = 0
    var symptomName: String
    var id = UUID().uuidString
    
    /// filters out rating sent that are not between start and end
    init(start: Date, end: Date, symptomName: String ,ratings: [Rating]? = nil) {
        
        self.start = start
        self.end = end
        self.symptomName = symptomName
        
        let inDateRange = ratings?.filter({ rating in
            if rating.ratedSymptom == nil { return false }
            else if rating.ratedSymptom!.name != symptomName { return false }
            if rating.date < start { return false}
            else if rating.date > end { return false }
            else { return true }
        })
        
        ratingsCount = inDateRange?.count ?? 0
        
        guard ratingsCount > 0 else { return }
        
        average = inDateRange!.compactMap { $0.vas }.reduce(0, +) / Double(ratingsCount)
    }
    
}
