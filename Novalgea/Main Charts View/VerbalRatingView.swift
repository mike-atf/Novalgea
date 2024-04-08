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
//                Circle()
//                    .fill(Color.duskBlue)
//                    .strokeBorder(lineWidth: 3)
//                RoundedRectangle(cornerRadius: 6)
//                .fill(Color.duskBlue)
//                .strokeBorder(lineWidth: 3)
                
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
            
            //MARK: - VAS indicator on outside of circle
//            ZStack(alignment: .top) {
//                Circle()
//                    .hidden()
//                Indicator()
//                    .stroke(Color.black, lineWidth: 1)
//                    .fill(getColor(vas: (vas ?? 0)))
//                    .frame(width: 35, height: 25)
//                    .offset(y: -20)
//                
//                Text((vas ?? 0.0),format: .number.precision(.fractionLength(1)))
//                    .foregroundStyle(indicatorTextColor(vas: vas ?? 0))
//                    .font(.system(size: 14))
//                    .bold()
//                    .offset(y:-15)
//            }
//            .rotationEffect(Angle(radians: (vas ?? 0.0)/10 * (-2 * .pi)))

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
