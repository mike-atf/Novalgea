//
//  ErrorManager.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//

import Foundation
import CoreData
import OSLog

struct IntError: Codable {
    
    var date: Date
    var file: String
    var function: String
    var osError: String?
    var appError: String?
    
    init(date: Date, file: String, function: String, osError: String?, appError: String?) {
        self.date = date
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
        
        let context = PersistenceController.shared.container.viewContext
        
        let errorFetch = NSFetchRequest<InternalError>(entityName: "InternalError")
        
        let filePredicate = NSPredicate(format: "file == %@", argumentArray: [error.file])
        let functionPredicate = NSPredicate(format: "function == %@", argumentArray: [error.function])
        var predicates = [filePredicate, functionPredicate]

        if let sysErr = error.osError {
            let osEPredicate = NSPredicate(format: "osError == %@", argumentArray: [sysErr])
            predicates.append(osEPredicate)
        }
        
        if let appErr = error.appError {
            let appEPredicate = NSPredicate(format: "appError == %@", argumentArray: [appErr])
            predicates.append(appEPredicate)
        }

        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        errorFetch.predicate = combinedPredicate
        
        do {
            if let sameError = try context.fetch(errorFetch).first {
                sameError.count += 1
                sameError.dates.append(error.date)
            }
            else {
                let newError = InternalError(context: context)
                newError.fromNewError(error: error)
            }
            
            try context.save()
            
        } catch {
            ErrorManager.addError(error: IntError(date: Date(), file: "ErrorManager", function: "addError", osError: error.localizedDescription, appError: "error fetching stored errors"))
        }
    }
    
    
    
}
