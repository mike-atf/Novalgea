//
//  EventDescriptionView.swift
//  Novalgea
//
//  Created by aDev on 14/04/2024.
//

import SwiftUI
import OSLog

struct EventDescriptionView: View {
    
    @Binding var selectedEvent: DiaryEvent?
    @Binding var eventIndex: Int?
    
    var allEventsInRange: [DiaryEvent]

    var body: some View {
        
        VStack(alignment: .leading) {
            if selectedEvent != nil {
                HStack {
                    Button {
                        if eventIndex ?? 0 > 0 {
                            eventIndex! -= 1
                            selectedEvent = allEventsInRange[eventIndex ?? 0]
                        }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                    }
                    .disabled(eventIndex == 0)

                    Text(UserText.term("Selected: ")).font(.body).bold()
                    Text(selectedEvent!.date.formatted(date: .abbreviated, time: .shortened)).font(.footnote)
                    
                    Button {
                        withAnimation {
                            selectedEvent = nil
                        }
                    } label: {
                        Image(systemName: "eye.slash.circle.fill")
                    }

                    Spacer()
                    
                    Button {
                            eventIndex! += 1
                            selectedEvent = allEventsInRange[eventIndex ?? 0]
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                    }
                    .disabled(eventIndex == allEventsInRange.count-1)

                }
                VStack(alignment: .leading) {
                    Text(selectedEvent!.category?.name ?? UserText.term("missing")).font(.footnote)
                    Text(selectedEvent!.notes).font(.footnote)
                }
            }
            else {
                HStack {
                    Text(UserText.term("No event selected")).bold()
                }
            }
        }
    }
}

//#Preview {
//    EventDescriptionView(event: .constant(DiaryEvent.preview), allEventsInRange: .constant([DiaryEvent.preview]))
//}
