//
//  ReviewDates.swift
//  Novalgea
//
//  Created by aDev on 15/02/2024.
//

import Foundation

struct ReviewDates { //: NSObject, NSCoding, Codable
    
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

//    func encode(with aCoder: NSCoder) {
//        if let date = proposedReviewDate {
//            aCoder.encode(date, forKey: "proposedReviewDate")
//        }
//        if let date = proposedStopDate {
//            aCoder.encode(date, forKey: "proposedStopDate")
//        }
//        if let date = nextMildSevereReviewDate {
//            aCoder.encode(date, forKey: "nextMildSevereReviewDate")
//        }
//        if let date = nextOverdoseCheckDate {
//            aCoder.encode(date, forKey: "nextOverdoseCheckDate")
//        }
//        if let date = nextEffectCheckDate {
//            aCoder.encode(date, forKey: "nextEffectCheckDate")
//        }
//    }
//    
//    func archiveDates() throws -> Data? {
//        
//        let dates = [proposedReviewDate, proposedStopDate, nextMildSevereReviewDate, nextOverdoseCheckDate, nextEffectCheckDate]
//        
//        return try NSKeyedArchiver.archivedData(withRootObject: dates, requiringSecureCoding: false)
//     }
//    
//    func unarchiveDates(data: Data?) throws {
//        
//        guard data != nil else {
//            proposedReviewDate = nil
//            proposedStopDate = nil
//            nextMildSevereReviewDate = nil
//            nextOverdoseCheckDate = nil
//            nextEffectCheckDate = nil
//            return
//        }
//        
//        let dates = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSDate.self, from: data!)
//        
//        var count = 0
//        for date in dates ?? [] {
//            
//            switch count {
//            case 0:
//                proposedReviewDate = date as Date
//            case 1:
//                proposedStopDate = date as Date
//            case 2:
//                nextMildSevereReviewDate = date as Date
//            case 3:
//                nextOverdoseCheckDate = date as Date
//            case 4:
//                nextEffectCheckDate = date as Date
//            default:
//               throw InternalError(file: "", function: "", appError: "error")
//            }
//            
//            count += 1
//        }
//    }
//    
    
    
//    convenience init(reviewDate:Date?, stopDate:Date?, nextMildSevereReview: Date?, overdoseCheckDate: Date?, nextEffectCheckDate: Date?) {
//        self.init()
//        
//        self.proposedStopDate = stopDate
//        self.proposedReviewDate = reviewDate
//        self.nextMildSevereReviewDate = nextMildSevereReview
//        self.nextOverdoseCheckDate = overdoseCheckDate
//        self.nextEffectCheckDate = nextEffectCheckDate
//        
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        guard let date1 = aDecoder.decodeObject(forKey: "proposedReviewDate") as? Date,
//            let date2 = aDecoder.decodeObject(forKey: "proposedStopDate") as? Date,
//            let date3 = aDecoder.decodeObject(forKey: "nextMildSevereReviewDate") as? Date,
//            let date4 = aDecoder.decodeObject(forKey: "nextOverdoseCheckDate") as? Date,
//            let date5 = aDecoder.decodeObject(forKey: "nextEffectCheckDate") as? Date
//        else { return nil }
//        
//        self.init(reviewDate: date1, stopDate: date2, nextMildSevereReview: date3, overdoseCheckDate: date4, nextEffectCheckDate: date5)
//    }
    
    
}
