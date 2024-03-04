//
//  Extension Date.swift
//  Novalgea
//
//  Created by aDev on 29/02/2024.
//

import Foundation

extension Date {
    
    func setDate(day: Int, month: Int, year: Int) -> Date? {
        
        guard day < 32 else { return nil }
        guard month < 12 else { return nil }
        let range = 2000 ... 2100
        guard range.contains(year) else { return nil }
        
        let components: Set<Calendar.Component> = [.year, .month, .day]

        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: Date())
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year

        return Calendar.autoupdatingCurrent.date(from: dateComponents)
    }
}
