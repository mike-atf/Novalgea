//
//  ReviewDates.swift
//  Novalgea
//
//  Created by aDev on 15/02/2024.
//

import Foundation

struct ReviewDates {
    
    var proposedReviewDate: Date? // first 4 week trial, then e.g every 6 months.
    var proposedStopDate: Date? // for regular or frequenty used opioids or NSAIDS
    var nextMildSevereReviewDate: Date?
    var nextOverdoseCheckDate: Date?
    var nextEffectCheckDate: Date?
    
    init(proposedReviewDate: Date? = nil, proposedStopDate: Date? = nil, nextMildSevereReviewDate: Date? = nil, nextOverdoseCheckDate: Date? = nil, nextEffectCheckDate: Date? = nil) {
        self.proposedReviewDate = proposedReviewDate
        self.proposedStopDate = proposedStopDate
        self.nextMildSevereReviewDate = nextMildSevereReviewDate
        self.nextOverdoseCheckDate = nextOverdoseCheckDate
        self.nextEffectCheckDate = nextEffectCheckDate
    }
    
    public func convertToData() -> Data? {
        
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

}
