//
//  Extension String Array.swift
//  Novalgea
//
//  Created by aDev on 16/02/2024.
//

import Foundation

extension Array where Element == String {
    
    func combinedString() -> String {
        
        var str = self.first ?? String()
        if self.count > 1 {
            for i in 1..<self.count {
                str += ", \(self[i])"
            }
        }
        return str
    }

}
