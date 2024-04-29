//
//  DatesManager.swift
//  Novalgea
//
//  Created by aDev on 06/03/2024.
//

import Foundation

class DatesManager {
    
    /// returns [first day of month 00:00, last day of month 23:59:59]
    class func monthStartAndEnd(ofDate: Date) -> [Date] {
        
        let components: Set<Calendar.Component> = [.year, .month, .weekday, .day, .hour, .minute]

        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: ofDate)
        dateComponents.second = 0
        dateComponents.minute = 0
        dateComponents.hour = 0
        dateComponents.day = 1
        
        let firstDayDate = Calendar.autoupdatingCurrent.date(from: dateComponents) ?? Date()

        dateComponents.second = 59
        dateComponents.minute = 59
        dateComponents.hour = 23
        dateComponents.month! += 1
        dateComponents.day! = 1

        let lastDayDate = (Calendar.autoupdatingCurrent.date(from: dateComponents) ?? Date()).addingTimeInterval(-24*3600)
        
        return [firstDayDate, lastDayDate]

    }
    
    class func dayStartAndEnd(ofDate: Date) -> [Date] {
        
        let components: Set<Calendar.Component> = [.year, .month, .weekday, .day, .hour, .minute]

        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: ofDate)
        dateComponents.second = 0
        dateComponents.minute = 0
        dateComponents.hour = 0
        
        let firstDayDate = Calendar.autoupdatingCurrent.date(from: dateComponents) ?? ofDate

        let lastDayDate = firstDayDate.addingTimeInterval(24*3600-1)
        
        return [firstDayDate, lastDayDate]

    }
    
    
    /// returns beginning of day offset by 'days' from a given date, or .now as default; for end of a day use this function and add timeInterval -1
    class func startOfDay(from: Date = .now, _by days: Int) -> Date {
        
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: from)
        dateComponents.day! += days
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
    }
    
    class func startOfWeek(from: Date = .now, _by weeks: Int) -> Date {
        
        let components: Set<Calendar.Component> = [.year,.weekOfYear ,.month, .weekday, .hour, .minute]
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: from)
        dateComponents.weekOfYear! += weeks
        
        if dateComponents.weekOfYear! < 0 {
            dateComponents.weekOfYear! += 52
            dateComponents.year! -= 1
        } else if dateComponents.weekOfYear! > 52 {
            dateComponents.weekOfYear! -= 52
            dateComponents.year! += 1
        }
        
        dateComponents.weekday! = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
    }
    
    // 1 = Sunday, 7 = Saturday
    class func weekday(of: Date) -> Int {
        let components: Set<Calendar.Component> = [.weekday]
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: of)
        return dateComponents.weekday! - 1 // change to 0...6 to match weekDayNames
    }


    
    class func startOfMonth(from: Date = .now, _by months: Int) -> Date {
        
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: from)
        dateComponents.month! += months
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
    }
    
    class func daysOfMonth(from: Date) -> Int {
        
        let components: Set<Calendar.Component> = [.year, .month, .day]
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: from)
        dateComponents.day = 1
        
        let start = Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
        dateComponents.month! += 1
        dateComponents.day! -= 1
        let end = Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
        
        let days = end.timeIntervalSince(start) / (24*3600)
        
        return Int(days) + 1
    }

    
    /// returns beginning of quarter offset by 'quarters' from a given date, or .now as default; for end of a quarter use this function and add timeInterval -1
    class func startOfQuarter(from: Date = .now, _by quarters: Int) -> Date {
        
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: from)
        
        var quarterStartMonth: Int
        
        switch dateComponents.month! {
            case 1,2,3:
            quarterStartMonth = 1
            case 4,5,6:
            quarterStartMonth = 4
            case 7,8,9:
            quarterStartMonth = 7
            case 10,11,12:
            quarterStartMonth = 10
            default: quarterStartMonth = 1
        }
        quarterStartMonth += (quarters * 3)
        
        if quarterStartMonth < 0 {
            quarterStartMonth += 12
            dateComponents.year! -= 1
        } else if quarterStartMonth > 12 {
            quarterStartMonth -= 12
            dateComponents.year! += 1
        }
        
        dateComponents.month = quarterStartMonth
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0

        return Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
    }

    class func startOfYear(from: Date = .now, _by years: Int) -> Date {
        
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: from)
        
        dateComponents.year! += years
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return Calendar.autoupdatingCurrent.date(from: dateComponents) ?? from
    }


    
    /// returns the Sunday - Saturday or equivalent or the week of the date provided
    class func weekStartAndEnd(ofDate: Date) -> [Date] {
                
        let calendar = Calendar.autoupdatingCurrent
        
        let dayOfWeek = calendar.component(.weekday, from: ofDate) - calendar.firstWeekday
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: ofDate)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - (dayOfWeek+2), to: ofDate) }

        let weekStart = calendar.startOfDay(for: days.first!)
        return [weekStart, weekStart.addingTimeInterval(7*24*3600)]
    }
    
    class func quarterStartAndEnd(ofDate: Date) -> [Date] {
                
        let calendar = Calendar.autoupdatingCurrent
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: ofDate)))!

        var components = calendar.dateComponents([.month, .day , .year],from: startOfMonth)
        var quarterStartMonth: Int
        
        switch components.month! {
            case 1,2,3:
            quarterStartMonth = 1
            case 4,5,6:
            quarterStartMonth = 4
            case 7,8,9: quarterStartMonth = 7
            quarterStartMonth = 7
            case 10,11,12: quarterStartMonth = 10
            quarterStartMonth = 10
            default: quarterStartMonth = 1
        }
        
        components.month = quarterStartMonth
        let qStart = Calendar.current.date(from: components)!
        return [qStart, qStart.addingTimeInterval((365*24*3600)/4-1)]

    }
    
    class func yearStartAndEnd(ofDate: Date) -> [Date] {
        
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]

        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(components, from: ofDate)
        dateComponents.second = 0
        dateComponents.minute = 0
        dateComponents.hour = 0
        dateComponents.day = 1
        dateComponents.month = 1

        let yearStart = Calendar.autoupdatingCurrent.date(from: dateComponents)!
        
        dateComponents.second = 59
        dateComponents.minute = 59
        dateComponents.hour = 23
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.year! += 1

        let yearEnd = (Calendar.autoupdatingCurrent.date(from: dateComponents)!).addingTimeInterval(-24*3600)
        
        return [yearStart, yearEnd]

    }


    class func displayPeriodTerm(_for option: DisplayTimeOption, start: Date, end: Date) -> String {
                
        switch option {
        case .day:
            return start.formatted(.dateTime.weekday().day().month())
        case .week:
            return start.formatted(.dateTime.weekday().day().month()) + " - " + end.formatted(date: .abbreviated, time: .omitted)
        case .month:
            return start.formatted(.dateTime.month().year())
        case .quarter:
            let midDate = start.addingTimeInterval(24*3600*365/8)
            return midDate.formatted(.dateTime.quarter().year())
        case .year:
            return start.formatted(.dateTime.year())
        }
    }


}
