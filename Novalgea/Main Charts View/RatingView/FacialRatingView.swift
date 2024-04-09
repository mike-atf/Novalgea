//
//  FacialRatingView.swift
//  Novalgea
//
//  Created by aDev on 05/04/2024.
//

import SwiftUI

struct FacialRatingView: View {
    
    @Binding var vas: Double?
    var textSize: CGFloat
    
    var body: some View {
        Text(emoji()).font(.system(size: textSize)).transition(.move(edge: .trailing))
    }
    private func emoji() -> String {
        
        let expressions = ["🙂","😐","🫤","😕","🙁","☹️","😣","😖","😩","😫"]

        var i = Int(vas ?? 0)
        if i > expressions.count-1 { i = expressions.count-1 }
        return expressions[i]
        
        
    }
}

#Preview(traits: .landscapeLeft) {
    FacialRatingView(vas: .constant(0), textSize: 25)
        
}


//struct HalfFaceView: View {
//    
//    @Binding var vas: Double?
//    
//    var body: some View {
//        
//        GeometryReader { reader in
//            
//            ZStack {
//                
//                let smaller = min(reader.size.width, reader.size.height)
//                let greater = max(reader.size.width, reader.size.height)
//                
//                
//                Ellipse()
//                    .fill(.white)
//                    .frame(width: greater * 0.2,height: greater * 0.3)
//                    .offset(x:smaller * 0.5 - greater * 0.12, y: -reader.size.height * 0.11)
//                
//                LeftBrow()
//                    .stroke(.white, style: StrokeStyle(lineWidth: greater/16, lineCap: .round))
//                LeftMouth()
//                    .stroke(.white, style: StrokeStyle(lineWidth: greater/16, lineCap: .round))
//
//            }
//        }
//    }
//}
//
//
//struct LeftBrow: Shape {
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let max = max(rect.width, rect.height)
//       // 'center' places the arc inside the rect, smaller y=upwards, smaller x=leftwards
//        // angle = north = -90 or 270, east = 0, south = 90, west = 180
//        // clockwise is reversed in iOS, so entering true gives counter-clockwise drawing
//        path.addArc(center: CGPoint(x: rect.width - max*0.15, y: rect.height - max * 0.75), radius: rect.height/7, startAngle: Angle(degrees: 220), endAngle: Angle(degrees: 305), clockwise: false)
//        return path
//    }
//}
//
//struct Eye: Shape {
//    
//    var left: Bool
//    
//    func path(in rect: CGRect) -> Path {
//        
//        let min = min(rect.size.width, rect.size.height)
////        let max = max(rect.size.width, rect.size.height)
//
//        let width = min/5
//        let height = width * 1.5
//        let shiftFromMiddle = left ? min * -0.15 : min * 0.15
//        
//        let eyeRect = CGRect(x: rect.midX + shiftFromMiddle - width/2 , y: rect.midY - rect.height/7 - height/2, width: width, height: height)
//        return Path(ellipseIn: eyeRect)
//    }
//}
//
//struct Mouth: Shape {
//    
//    func path(in rect: CGRect) -> Path {
//        
//        var path = Path()
//        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.height * 0.38, startAngle: Angle(degrees: 50), endAngle: Angle(degrees: 130), clockwise: false)
//
//        return path
//    }
//}
//
//struct LeftBrow2: Shape {
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let max = max(rect.width, rect.height)
//       // 'center' places the arc inside the rect, smaller y=upwards, smaller x=leftwards
//        // angle = north = -90 or 270, east = 0, south = 90, west = 180
//        // clockwise is reversed in iOS, so entering true gives counter-clockwise drawing
//        path.addArc(center: CGPoint(x: rect.midX - max*0.15, y: rect.height - max * 0.75), radius: rect.height/7, startAngle: Angle(degrees: 220), endAngle: Angle(degrees: 305), clockwise: false)
//        return path
//    }
//}
//
//
//struct LeftMouth: Shape {
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.height * 0.38, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 140), clockwise: false)
//
//        return path
//    }
//}

