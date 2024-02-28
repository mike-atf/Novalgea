//
//  Extension Doses.swift
//  Novalgea
//
//  Created by aDev on 19/02/2024.
//

import Foundation

extension Array where Element == Dose {
    
    func convertToData() -> [Data] {
        
        var dataArray = [Data]()
        
        for dose in self {
            if let data = dose.convertToData() {
                dataArray.append(data)
            }
        }
        return dataArray
    }
}
