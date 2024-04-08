//
//  CategoryListView.swift
//  Novalgea
//
//  Created by aDev on 28/03/2024.
//

import SwiftUI
import SwiftData


struct CategoryListView: View {
        
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EventCategory.name, animation: .default) var categories: [EventCategory]

    var body: some View {
        List(categories) { cat in
            VStack(alignment: .leading) {
                Text(cat.name).bold()
                Text(cat.relatedDiaryEvents?.count ?? 0, format: .number)
            }
        }
    }
}

#Preview {
    CategoryListView()
}
