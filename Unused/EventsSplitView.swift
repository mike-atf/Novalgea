//
//  EventsSplitView.swift
//  Novalgea
//
//  Created by aDev on 21/04/2024.
//

import SwiftUI

//struct EventsSplitView: View {
//    
//    @State var path = NavigationPath()
//    @State var selection: DiaryEvent?
//    @State var showEditView: Bool = false
//    @State private var columnVisibility = NavigationSplitViewVisibility.all
//    
//
//
//    var body: some View {
//        
//        NavigationSplitView(columnVisibility: $columnVisibility) {
//            DiaryEventsListView(selection: $selection, path: $path, showEditView: $showEditView)
//        } detail: {
//            NavigationStack(path: $path) {
//                if selection != nil {
//                    NewEventView(selectedEvent: $selection, createNew: false)
////                    EventEditView(event: $selection, path: $path)
//                }
//            }
//        } 
////        detail: {
////            if showNewCategoryView {
////                NewCategoryView(show: $showNewCategoryView)
////            }
////        }
//
//    }
//}
//
//#Preview {
//    EventsSplitView()
//}
