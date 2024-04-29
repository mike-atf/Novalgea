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

    @State var selection: EventCategory?
    @State var showAddSheet: Bool = false
    
    var body: some View {
        
        NavigationSplitView {
            
            List(categories, selection: $selection) { category in
                
                NavigationLink(value: category) {
                    HStack(alignment: .top) {
                        VStack {
                            Circle()
                                .fill(category.color())
                                .frame(height: 15)
                            Text(category.symbol)
                        }
                        .padding(.trailing)
                        HStack {
                            Text(category.name).bold()
                            Spacer()
                            Text((category.relatedDiaryEvents?.count ?? 0).formatted())
                        }
                    }
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        delete(category: category)
                    }
                }
            }
            .navigationDestination(item: $selection, destination: { _ in
                NewCategoryView(forSelectedEvent: .constant(nil), selectedCategory: $selection, createNew: false)
            })
            .navigationTitle(UserText.term("Event categories"))
            .overlay {
                if categories.isEmpty {
                    ContentUnavailableView {
                        Label(UserText.term("No ctegories yet"), systemImage: "bolt.circle")
                    } description: {
                        Text(UserText.term("Categories you create will be listed here"))
                    }
                }
            }
//            .toolbar {
//                Spacer()
//                Button {
//                    showAddSheet = true
//                } label: {
//                    Label("Add", systemImage: "plus")
//                }
//            }
        }
    detail: {
        if selection != nil {
            NavigationStack {
                
            }
        }
    }
    }
    
    private func delete(category: EventCategory) {
        modelContext.delete(category)
        saveContext()
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "CategoryListView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }

}

#Preview {
    CategoryListView()
}
