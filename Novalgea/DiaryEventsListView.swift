//
//  DiaryEventsListView.swift
//  Novalgea
//
//  Created by aDev on 18/02/2024.
//

import SwiftUI
import SwiftData

struct DiaryEventsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEvent.date, order: .reverse ,animation: .default) var events: [DiaryEvent]

    @State private var selection: DiaryEvent?
    
    var body: some View {
        
        NavigationSplitView {
            List{
                ForEach(events) { event in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(event.category!.name)
                            Spacer()
                            Text(event.date.formatted())
                        }
                        Text(event.notes).font(.footnote)
                    }
                }
            }
            .overlay {
                if events.isEmpty {
                    ContentUnavailableView {
                        Label("No Events", systemImage: "calendar.circle")
                    } description: {
                        Text("Your diary events will appear here.")
                    }
                }
            }
            .toolbar {
                Spacer()
                Button {
                } label: {
                    Label("Add event", systemImage: "plus")
                }
            }

        }
        detail: {
            if let selection = selection {
                NavigationStack {
                    
                }
            }
        }

    }
}

#Preview {
    DiaryEventsListView().modelContainer(DataController.previewContainer)
}
