//
//  ErrorDetailView.swift
//  Novalgea
//
//  Created by aDev on 11/02/2024.
//

import SwiftUI

struct ErrorDetailView: View {
    
    @Binding var error: InternalError
    
    @State var showDates: Bool = false
    
    var body: some View {
        
            List {
                if error.dates.count < 2 {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("File:").font(.title)
                                Text("\(error.file)")
                            }
                            HStack {
                                Text("Function:").font(.title2)
                                Text("\(error.function)")
                            }
                            Divider()
                            Text(error.appError)
                            Divider()
                            Text(error.osError ?? "OS: -")
                            Divider()
                            Text(error.dates.first!.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                }
                else {
                    NavigationLink(destination: ErrorDatesView(dates: error.dates)) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("File:").font(.title2)
                                    Text("\(error.file)")
                                }
                                HStack {
                                    Text("Function:").font(.title2)
                                    Text("\(error.function)")
                                }
                                Divider()
                                Text(error.appError)
                                Divider()
                                Text(error.osError ?? "OS: -")
                                Divider()
                                Text("\(error.count) error dates")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Details")
    }
}

#Preview {
    ModelContainerPreview(DataController.inMemoryContainer) {
        ErrorDetailView(error: .constant(InternalError.preview))
    }}
