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
    
    func dayOfMonth() -> Int {
        
        let components: Set<Calendar.Component> = [.month, .year, .day]
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: self)
        return dateComponents.day!
    }

    
    func month() -> Int {
        
        let components: Set<Calendar.Component> = [.month]
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: self)
        return dateComponents.month!
    }
    
    func year() -> Int {
        
        let components: Set<Calendar.Component> = [.year]
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: self)
        return dateComponents.year!
    }

}
