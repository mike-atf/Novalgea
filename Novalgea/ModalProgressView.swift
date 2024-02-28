//
//  ModalProgressView.swift
//  Novalgea
//
//  Created by aDev on 21/02/2024.
//

import SwiftUI

struct ModalProgressView: View {
    
    var message: String
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).foregroundColor(.blue)
            VStack {
//                HStack {
//                    Text(UserText.term(e: "Processing..."))
                    ProgressView(value: progress, total: 1.0)
//                }
                
//                Button {
//                    print("user cancelled")
//                } label: {
//                    Text("Cancel")
//                }.foregroundColor(.black)

            }
        }
    }
}

#Preview {
    ModalProgressView(message: "Message", progress: .constant(Double()))
}
