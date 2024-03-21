//
//  Extension Color Array.swift
//  Novalgea
//
//  Created by aDev on 20/03/2024.
//

import SwiftUI

extension Array where Element == Color {
    
    func getColor(_for vas: CGFloat) -> Color {
        
        let vas0_1 = vas/10.0
        
        let angularGradientColors = [.white, Color(red: 251/255, green: 247/255, blue: 118/255), Color(red: 255/255, green: 161/255, blue: 34/255), Color(red: 151/255, green: 60/255, blue: 56/255)]
        
        let cgColors: [CGColor] = angularGradientColors.compactMap { color in
            color.cgColor
        }
        
        if vas0_1 <= 0.0 { return angularGradientColors[0] }
        else if vas0_1 >= 1.0 { return angularGradientColors[3] }
        
                    
        guard let rgbComponents1 = cgColors[0].components else { return Color.white }
        guard let rgbComponents2 = cgColors[1].components else { return Color.white }
        guard let rgbComponents3 = cgColors[2].components else { return Color.white }
        guard let rgbComponents4 = cgColors[3].components else { return Color.white }

        var firstColorComponents = [CGFloat]()
        var secondColorComponents = [CGFloat]()
        var multiplier: CGFloat = 0.0

        switch vas0_1 {
        case 0.0...0.33:
                
            firstColorComponents = rgbComponents1
            secondColorComponents = rgbComponents2
            multiplier = vas0_1 * 3
            
        case 0.33...0.67:
            
            firstColorComponents = rgbComponents2
            secondColorComponents = rgbComponents3
            multiplier = (vas0_1 - 0.33) * 3

        case 0.67...1.0:
            firstColorComponents = rgbComponents3
            secondColorComponents = rgbComponents4
            multiplier = (vas0_1 - 0.67) * 3

        default:
            
            return Color.purple
        }
        
        let r1 = firstColorComponents[0]
        let r2 = secondColorComponents[0]
        let rdifference = r2 - r1
        let newRed = r1 + rdifference * multiplier
        
        let g1 = firstColorComponents[1]
        let g2 = secondColorComponents[1]
        let gdifference = g2 - g1
        let newGreen = g1 + gdifference * multiplier
        
        let b1 = firstColorComponents[2]
        let b2 = secondColorComponents[2]
        let bdifference = b2 - b1
        let newBlue = b1 + bdifference * multiplier

        return Color(red: newRed, green: newGreen, blue: newBlue)
        
    }
    
}
