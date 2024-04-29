//
//  DiaryEventsListView.swift
//  Novalgea
//
//  Created by aDev on 18/02/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct DiaryEventsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DiaryEvent.date, order: .reverse ,animation: .default) var events: [DiaryEvent]
    @Query var categories: [EventCategory]

    @State var selection: DiaryEvent?
    @State var path = NavigationPath ()
    
    var body: some View {
        
        NavigationSplitView {
            
            List(events, selection: $selection) { event in
                
                NavigationLink(value: event) {
                    HStack(alignment: .top) {
                        VStack {
                            Circle()
                                .fill(event.category?.color() ?? Color.primary)
                                .frame(height: 15)
                            Text(event.category?.symbol ?? "-")
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text(event.notes).font(.footnote)
                            }
                            HStack {
                                Text(event.date.formatted()).font(.footnote)
                                if let end = event.endDate {
                                    Text(" - ")
                                    Text(end.formatted()).font(.footnote)
                                }
                            }
                        }
                    }
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        delete(event: event)
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
            .overlay {
                if events.isEmpty {
                    ContentUnavailableView {
                        Label("No Events", systemImage: "calendar.circle")
                    } description: {
                        Text("Your diary events will appear here.")
                    }
                }
            }
        }
        detail: {
            NavigationStack(path: $path) {
                if selection != nil {
                    NewEventView(selectedEvent: $selection, createNew: .constant(false))
                }
            }
        }
    }
    
    private func delete(event: DiaryEvent) {
        modelContext.delete(event)
        saveContext()
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "DiaryEventListView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }

}

#Preview {
    DiaryEventsListView(selection: nil).modelContainer(DataController.previewContainer)
}
