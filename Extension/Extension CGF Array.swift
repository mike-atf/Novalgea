//
//  Extension CGF Array.swift
//  Novalgea
//
//  Created by aDev on 13/04/2024.
//

import SwiftUI


extension Array where Element == CGFloat {
    
    func getColor() -> Color {
        
        guard self.count == 4 else { return Color.primary }
        
        return Color(.sRGB, red: self[0], green: self[1], blue: self[2])

    }
    
}
