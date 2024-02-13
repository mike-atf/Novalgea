//
//  ErrorManager.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//

import SwiftUI
import SwiftData
import OSLog


@MainActor
class ErrorManager {
    
    static let shared = ErrorManager()
    
    class func addError(error: InternalError, container: ModelContainer) {
        
        let logger = Logger()
        var message = error.file + "/ " + error.function
        message += (error.osError ?? "OS -") + (error.appError)
        logger.error("\(message)")
        
        let appError = error.appError
        let osError = error.osError
        let file = error.file
        let function = error.function
        
        do {

            let predicate = #Predicate<InternalError> { intError in
                (intError.appError == appError) &&
                (intError.osError == osError) &&
                intError.file == file &&
                intError.function == function
            }
            
            let fetchDescriptor = FetchDescriptor<InternalError>(predicate: predicate)
            let matchingErrors = try container.mainContext.fetch(fetchDescriptor)
            if matchingErrors.count > 0 {
                let first = matchingErrors.first
                first!.count += 1
                first?.dates.append(Date.now)
                logger.info("\("duplicate error found and count increased")")
            }
            else {
                container.mainContext.insert(error)
                logger.info("\("new error encountered and stored")")
            }
            try container.mainContext.save()
        } catch {
            message = "Error in ErrorManager.addError in ErrorManager: \(error.localizedDescription)"
            logger.error("\(message)")
        }
            

    }
    
}
