//
//  ErrorManager.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct IntError: Codable {
    
    var date: Date
    var file: String
    var function: String
    var osError: String?
    var appError: String?
    
    init(file: String, function: String, osError: String?, appError: String?) {
        self.date = Date()
        self.file = file
        self.function = function
        self.osError = osError
        self.appError = appError
    }
}


class ErrorManager {
    
    
    static let shared = ErrorManager()
    
    class func addError(error: IntError) {
        
        let logger = Logger()
        var message = error.file + "/ " + error.function
        message += (error.osError ?? "OS -") + (error.appError ?? "App -")
        logger.error("\(message)")
        
    }
    
}
