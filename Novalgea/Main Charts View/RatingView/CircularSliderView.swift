//
//  CircularSliderView.swift
//  Novalgea
//
//  Created by aDev on 04/04/2024.
//

import SwiftUI

struct CircularSliderView: View {
    
    @Binding var vas: Double?
    @Binding var selectedVAS: Double?
    @Binding var showNewEventView: Bool
    @Binding var showNewMedicineEventView: Bool
    @Binding var showSymptomsList: Bool
    @Binding var showView: Bool
    @Binding var headerSubTitle: String

    private let angulargradient = AngularGradient(colors: gradientColors, center: .center, startAngle: .degrees(270), endAngle: .degrees(-90))

    var body: some View {
        
        GeometryReader { reader in

            let diameter = min(reader.size.width, reader.size.height)
            let rimWidth = diameter/4
            let topOfCircle = (reader.size.height - diameter)/2
            
            ZStack(alignment: .center) {

                ZStack(alignment: .top)  {
                    Circle()
                        .fill(.white)
                        .stroke(Color.primary, style: StrokeStyle(lineWidth:5)) // black outline
                        .strokeBorder(angulargradient, style: StrokeStyle(lineWidth: rimWidth))
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged({ value in
                                    let center = CGPoint(x: reader.frame(in: .local).midX, y: reader.frame(in: .local).midY)
                                    let distance = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                                    vasUpdate(location: distance)
                                })
                                .onEnded({ _ in
                                    vas = selectedVAS
                                    showSymptomsList = true
                                    headerSubTitle = UserText.term("Select symptom or side effect for VAS ") + (vas ?? 0).formatted(.number.precision(.fractionLength(1)))
                                })
                        )
                        .sensoryFeedback(.increase, trigger: selectedVAS)
                    Triangle()
                        .fill(Color.gradientRed)
                        .frame(width: diameter/15, height: rimWidth)
                        .offset(CGSize(width: -diameter/30, height: topOfCircle))

                    //MARK: - VAS indicator on outside of circle
                    Indicator()
                        .stroke(Color.black, lineWidth: 2)
                        .fill(getColor(vas: (selectedVAS ?? 0)))
                        .frame(width: diameter/8 , height: diameter/16)
                        .offset(y: topOfCircle - diameter/30)
                    
                    Text((selectedVAS ?? 0.0),format: .number.precision(.fractionLength(1)))
                        .foregroundStyle(indicatorTextColor(vas: selectedVAS ?? 0))
                        .font(.system(size: diameter/20)).bold()
                        .offset(y: topOfCircle - diameter/30)
                }

                //MARK: - Round button
                ZStack {
                    Circle()
                        .fill(Color.duskBlue)
                    VStack {
                        Button("Medicine", systemImage: "pills.circle.fill") {
                            withAnimation {
                                showView = false
                                showNewMedicineEventView = true
                            }
                        }
                        .font(.system(size: diameter/20)).bold()
                        .foregroundStyle(.white)
                        .padding(.bottom,diameter/50)
                        
                        Button("Event", systemImage: "square.and.pencil.circle.fill") {
                            withAnimation {
                                showView = false
                                showNewEventView = true
                            }
                        }
                        .font(.system(size: diameter/20)).bold()
                        .foregroundStyle(.white)
                        .padding(.top,diameter/50)
                    }
                }
                .padding(diameter/4 + 6)
            }
            .padding()
        }
            

    }
    
    func vasUpdate(location: CGPoint) {
        
        let vector = CGVector(dx: location.x, dy: location.y)
        let rawAngle = atan2(vector.dx, vector.dy) + .pi
        let angle = rawAngle < 0.0 ? rawAngle + 2 * .pi : rawAngle
        selectedVAS = angle / (2 * .pi) * 10 // TODO: - add in current symptom minVAS and maxVAS
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
    CircularSliderView(vas: .constant(0.0), selectedVAS: .constant(0.0), showNewEventView: .constant(false), showNewMedicineEventView: .constant(false), showSymptomsList: .constant(false), showView: .constant(true), headerSubTitle: .constant("Subtitle binding"))
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

struct Indicator: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY-rect.height/4))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-rect.height/4))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
    
    
    
}
