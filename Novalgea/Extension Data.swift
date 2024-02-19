//
//  Extension Data.swift
//  Novalgea
//
//  Created by aDev on 19/02/2024.
//

import Foundation

extension Data? {
    
    func convertToDoses() -> [Dose]? {
        
        guard let nonNil = self else { return nil }
        
        return try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSNumber.self, NSData.self, NSDate.self, NSString.self], from: nonNil) as? [Dose]
        
    }
    
    func convertToDates() -> [Date]? {
        
        guard let nonNil = self else { return nil }
        
        return try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSDate.self, NSData.self], from: nonNil) as? [Date]
        
    }

}
