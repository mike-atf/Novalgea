//
//  Extension Double Array.swift
//  Novalgea
//
//  Created by aDev on 24/04/2024.
//

import Foundation

extension Array where Element == Double {
    
    public func mean() -> Double {        
        return self.reduce(0, +) / Double(self.count)
    }
    
    
}
