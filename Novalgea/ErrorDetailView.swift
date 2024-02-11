//
//  ErrorDetailView.swift
//  Novalgea
//
//  Created by aDev on 11/02/2024.
//

import SwiftUI

struct ErrorDetailView: View {
    
    var error: InternalError
    
    var body: some View {
        
        NavigationLink(value: error) {
            VStack(alignment: .leading) {
                Text(error.appError)
                Text(error.osError ?? "OS: -")
                Text("\(error.count)")
            }
        }
    }
}

#Preview {
    ModelContainerPreview(DataController.inMemoryContainer) {
        ErrorDetailView(error: InternalError.preview)
    }}
