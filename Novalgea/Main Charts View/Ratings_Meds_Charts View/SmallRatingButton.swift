//
//  SmallRatingButton.swift
//  Novalgea
//
//  Created by aDev on 17/03/2024.
//

import SwiftUI

struct SmallRatingButton: View {
    
    @Binding var showRatingButton: Bool
    
    let angulargradient = AngularGradient(colors: gradientColors, center: .center, startAngle: .degrees(270), endAngle: .degrees(-90))

    
    var body: some View {
        
        GeometryReader { reader in

            let diameter = min(reader.size.width, reader.size.height)
            let rimWidth = diameter/4
            let topOfCircle = (reader.size.height - diameter)/2
            Button {
                withAnimation {
                    showRatingButton.toggle()
                }
            } label: {
                ZStack(alignment: .center) {
                    ZStack(alignment: .top)  {
                        Circle()
                            .fill(.white)
                            .stroke(Color.primary, style: StrokeStyle(lineWidth:diameter/40)) // dark outline
                            .strokeBorder(angulargradient, style: StrokeStyle(lineWidth: rimWidth))
                        Triangle()
                            .fill(Color.gradientRed)
                            .frame(width: diameter/15, height: rimWidth)
                            .offset(CGSize(width: -diameter/30, height: topOfCircle))
                    }
                    
                    //MARK: - Round button
                    ZStack {
                        Circle()
                            .fill(Color.duskBlue)
                        Cross()
                            .stroke(lineWidth: diameter/20)
                            .frame(width: diameter/4,height: diameter/4)
                            .foregroundStyle(.white)
                    }
                    .padding(diameter/5 + diameter/30)
                }
            }
        }

        
//        GeometryReader { reader in
//            
//            let min = min(reader.size.width, reader.size.height)
//            Button {
//                withAnimation {
//                    showRatingButton.toggle()
//                }
//            } label: {
//                ZStack(alignment: .center) {
//                    ZStack(alignment: .top) {
//                        Circle()
//                            .fill(Color.white)
//                            .strokeBorder(angulargradient, style: StrokeStyle(lineWidth: 10))
//                        Triangle()
//                            .fill(Color(red: 151/255, green: 60/255, blue: 56/255))
//                            .frame(width: 6, height: 10)
//                            .offset(CGSize(width: -3, height: 0)) //- 27
//                    }
//                    
//                    ZStack(alignment: .center) {
//                        Circle()
//                            .fill(Color(red: 0/255, green: 44/255, blue: 81/255))
//                        Image(systemName: "plus")
//                            .imageScale(.small)
//                            .foregroundStyle(.white)
//                    }
//                    .frame(width: min/4, height: min/4)
//                    
//                }
//            }
//        }

    }
}

#Preview {
    SmallRatingButton(showRatingButton: .constant(true))
}


struct Cross: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        return path
    }
    
    
    
}
