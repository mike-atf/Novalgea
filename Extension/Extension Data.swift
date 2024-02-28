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

extension Array where Element == Data {
    
    func convertToDoses() -> [Dose]? {
        
        var doses = [Dose]()
        
        for data in self {
            if let dose  = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDate.self, NSData.self, NSNumber.self], from: data) as? Dose {
                doses.append(dose)
            }
        }
        return doses
        
    }

    
}
