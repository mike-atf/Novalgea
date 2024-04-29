//
//  RatingsListView.swift
//  Novalgea
//
//  Created by aDev on 18/02/2024.
//

import SwiftUI
import SwiftData

struct RatingsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Rating.date, order: .reverse ,animation: .default) var ratings: [Rating]

    @State private var selection: Rating?

    var body: some View {
        
        NavigationSplitView {
            
            List(ratings, selection: $selection) { rating in
                
                NavigationLink(value: rating) {
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .fill(rating.ratedSymptom?.color() ?? Color.primary)
                                .frame(height: 20)
                            Text(rating.ratedSymptom?.name ?? "-")
                            Spacer()
                            Text(rating.vas,format: .number.precision(.fractionLength(1)))
                        }
                        Text(rating.date.formatted())
                    }

                }
            }
            .overlay {
                if ratings.isEmpty {
                    ContentUnavailableView {
                        Label("No Ratings", systemImage: "number.circle")
                    } description: {
                        Text("Your ratings will appear here.")
                    }
                }
            }
//            .toolbar {
//                Button {
//                    showNewRatingView = true
//                } label: {
//                    Label("Rating", systemImage: "plus")
//                }
//            }
        }
        detail: {

            NavigationStack {
                if selection != nil {
                    RatingEditView(rating: $selection)
                }
                
            }

        }

    }
    
}

#Preview {
    RatingsListView()
}
