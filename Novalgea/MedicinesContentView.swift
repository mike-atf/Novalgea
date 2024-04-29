//
//  MedicinesContentView.swift
//  Novalgea
//
//  Created by aDev on 28/04/2024.
//

import SwiftUI
import OSLog

struct MedicinesContentView: View {
    
//    @Binding var selectedMedicine: Medicine
    @Binding var viewOption: MedicineViewOption?
    @Binding var path: NavigationPath

    var medicineName: String
    
    var nonOptionalOption: Binding<MedicineViewOption> {
        Binding(
            get: { viewOption ?? .name },
            set: { viewOption = $0 }
        )
    }
    
    var body: some View {
        
        List(MedicineViewOption.allCases, selection: $viewOption) { option in
            
            NavigationLink(value: option) {
                HStack {
                    option.image().symbolRenderingMode(.hierarchical)
                        .padding(.trailing).imageScale(.large)
                    Text(UserText.term(option.rawValue)).font(.title2)                .foregroundStyle(.primary)

                }
            }
        }
        .navigationTitle(medicineName)
//        .onAppear {
//            if selectedMedicine.name == UserText.term("New medicine") {
//                viewOption = .name
////                path.append(NewMedicineView(medicine: $selectedMedicine, option: nonOptionalOption, path: $path))
//                path.append(viewOption)
//            }
//        }
    }
}

#Preview {
    MedicinesContentView(viewOption: .constant(.alerts), path: .constant(NavigationPath()), medicineName: "Med name")
}


enum MedicineViewOption: String, CaseIterable, Identifiable {
    case alerts = "Alerts"
    case name = "Name, ingredients, class, symptoms & notes"
    case doses = "Doses, frequencies & reminders"
    case titration = "Titration regime"
    
    var id: String { rawValue }
    
    public func image() -> Image {
        
        switch self {
        case .alerts:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .name:
            return Image(systemName: "square.and.pencil")
        case .doses:
            return Image(systemName: "calendar.badge.clock")
        case .titration:
            return Image(systemName: "arrow.up.right.square")
        }
    }
}
