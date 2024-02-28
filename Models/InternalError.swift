//
//  InternalError.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import SwiftUI
import SwiftData


@Model class InternalError: Identifiable, Error  {
    var appError: String = ""
    var count: Int64 = 0
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var dates: [Date] = [Date.now]
    var file: String = ""
    var function: String = ""
    var osError: String?
    var maxDate: Date = Date()
    
    
    public init(file: String, function: String, appError: String, osError: String?=nil, count: Int64?=1, dates:[Date]?=nil) {
        self.dates = dates ?? [Date()]
        self.file = file
        self.function = function
        self.count = count ?? 1
        self.osError = osError
        self.appError = appError
        maxDate = dates?.max() ?? .now
    }
    
    public func datesText() -> String {
        var text = String()
        for date in dates {
            text.append(date.formatted(date: .abbreviated, time: .shortened)+"\n")
        }
        return text
    }
    
    public func maxDates() -> Date {
        return dates.max()!
    }
}

extension InternalError {
    
    @MainActor
    static var previewContainer: ModelContainer {
        let container = try! ModelContainer(for: InternalError.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(InternalError(file: "a file", function: "a function", appError: "a sample error"))
        container.mainContext.insert(InternalError(file: "a file", function: "a function", appError: "a sample error"))

        return container
    }

    
    static var preview: InternalError {
        
        InternalError(file: "Sample error file", function: "Sample error function", appError: "sample app error", count: 2, dates: [Date.now, Date.now.addingTimeInterval(-24*3600)])
    }

}

