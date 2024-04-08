//
//  Extension EventCategory.swift
//  Novalgea
//
//  Created by aDev on 26/03/2024.
//

import Foundation

extension Array where Element == EventCategory {
    
    func category(named: String) -> EventCategory? {
        
        return self.filter { category in
            if category.name == named { return true }
            else { return false }
        }.first
    }
}
