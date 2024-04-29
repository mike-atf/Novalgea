//
//  ColorSelectionPicker.swift
//  Novalgea
//
//  Created by aDev on 13/04/2024.
//

import SwiftUI

struct ColorSelectionPicker: View {
    
    @Binding var selectedColor: Color
    
    var colorPalette: [Color]
    var image: Image?
    var imageColor: Color?

    var body: some View {
        
        HStack{
            if image != nil {
                image!.imageScale(.large)
                    .foregroundColor(imageColor!)
            }
            Text(UserText.term("Chose a color")).font(.title3).bold()
        }
            HStack() {
                ForEach(colorPalette, id: \.self) { color in
                    ZStack {
                        Circle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(color)
                        if color == selectedColor {
                            Image(systemName: "checkmark").foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 5)
                    .onTapGesture {
                        selectedColor = color
                    }
                }
            }
    }
}

#Preview {
    ColorSelectionPicker(selectedColor: .constant(Color.orange), colorPalette: ColorScheme.eventCategoryColorsArray)
}
