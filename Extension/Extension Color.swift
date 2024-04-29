//
//  Extension Color.swift
//  Novalgea
//
//  Created by aDev on 12/04/2024.
//

import SwiftUI

extension Color {
        
    func colorFromModel(model: [CGFloat]) -> Color {
        
        guard model.count == 4 else { return Color.primary }
        
        return Color( .sRGB, red: model[0], green: model[1], blue: model[2])
    }
    
    func modelFromColor() -> [CGFloat] {
                
        return UIColor(self).cgColor.components ?? [1.0,1.0,1.0,1.0,1.0]
    }

}
