//
//  RatingButton.swift
//  Novalgea
//
//  Created by aDev on 14/03/2024.
//

import SwiftUI
import CoreGraphics

struct RatingButton: View {
    
    private let gradientRed = Color(red: 151/255, green: 60/255, blue: 56/255)
//    private let gradientOrange = Color(red: 255/255, green: 161/255, blue: 34/255)
//    private let gradientYellow = Color(red: 251/255, green: 247/255, blue: 118/255)

    private let angulargradient = AngularGradient(colors: [.white, Color(red: 251/255, green: 247/255, blue: 118/255), Color(red: 255/255, green: 161/255, blue: 34/255), Color(red: 151/255, green: 60/255, blue: 56/255)], center: .center, startAngle: .degrees(270), endAngle: .degrees(-90))
    
    let segment = Angle(degrees: 5)
    
    var body: some View {
        GeometryReader { reader in
            
            let min = min(reader.size.width, reader.size.height)
            ZStack(alignment: .center) {
                ZStack(alignment: .top) {
                    Circle()
                        .fill(Color.white)
                        .stroke(Color.secondary, style: StrokeStyle(lineWidth:5))
                        .strokeBorder(angulargradient, style: StrokeStyle(lineWidth: reader.size.height * 0.25))
                    Triangle()
                        .fill(gradientRed)
                        .frame(width: 16, height: reader.size.height * 0.25)
                        .offset(CGSize(width: -8, height: 0)) //- 27
                }
                
                Button {
                    print("add")
                } label: {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(Color(red: 0/255, green: 44/255, blue: 81/255))
                        Image(systemName: "pills.fill")
                            .imageScale(.large)
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: min * 0.48,height: min * 0.48)
            }
        }
    }
}

#Preview {
    RatingButton()
}


struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        
        return path
    }
}

