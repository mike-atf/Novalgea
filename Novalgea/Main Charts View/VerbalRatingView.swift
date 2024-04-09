//
//  VerbalRatingView.swift
//  Novalgea
//
//  Created by aDev on 21/03/2024.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import CoreGraphics

struct VerbalRatingView: View {
        
    @Binding var vas: Double?
    
    let textWidth = "None  -  bearable   -   mild   -   discomforting   -   distressing   -   horrible   -   excruciating".widthOfString(usingFont: UIFont.systemFont(ofSize: 30, weight: .bold))
                                                                                                                                         
    var body: some View {
        
        ZStack {
            
            ZStack {
                
                GeometryReader { reader  in
                    
                    let widthDifference = textWidth - reader.size.width
                    let halfwidthDifference = (textWidth - widthDifference) / 2

                    LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                        .frame(minWidth: textWidth)
                        .offset(x: halfwidthDifference - (((vas ?? 0) + 0.4) / 11.3 * textWidth))
                        .mask {
                            
                            Text("None  -  bearable   -   mild   -   discomforting   -   distressing   -   horrible   -   excruciating").font(.system(size: 30))
                                .bold()
                                .frame(minWidth: textWidth) //, minHeight: reader.size.height
                                .offset(x: halfwidthDifference - (((vas ?? 0) + 0.4) / 11.3 * textWidth))
                        }
                }
                
            }
            .background(Color.duskBlue)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
        }
    }
    
    func getColor(vas: Double) -> Color {
        return gradientColors.getColor(_for: vas)
    }

    
    func indicatorTextColor(vas: Double) -> Color {
        
        if vas > 5 { return .white }
        else { return .black }
    }


}

#Preview {
    VerbalRatingView(vas: .constant(0.0))
}
