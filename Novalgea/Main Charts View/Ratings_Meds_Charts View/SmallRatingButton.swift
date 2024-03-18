//
//  SmallRatingButton.swift
//  Novalgea
//
//  Created by aDev on 17/03/2024.
//

import SwiftUI

struct SmallRatingButton: View {
    
    @Binding var showRatingButton: Bool
    
    
    var body: some View {
        
        GeometryReader { reader in
            
            let min = min(reader.size.width, reader.size.height)
            Button {
                withAnimation {
                    showRatingButton.toggle()
                }
            } label: {
                ZStack(alignment: .center) {
                    ZStack(alignment: .top) {
                        Circle()
                            .fill(Color.white)
                            .strokeBorder(angulargradient, style: StrokeStyle(lineWidth: 10))
                        Triangle()
                            .fill(Color(red: 151/255, green: 60/255, blue: 56/255))
                            .frame(width: 6, height: 10)
                            .offset(CGSize(width: -3, height: 0)) //- 27
                    }
                    
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(Color(red: 0/255, green: 44/255, blue: 81/255))
                        Image(systemName: "plus")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                    }
                    .frame(width: min/4, height: min/4)
                    
                }
            }
        }

    }
}

#Preview {
    SmallRatingButton(showRatingButton: .constant(true))
}
