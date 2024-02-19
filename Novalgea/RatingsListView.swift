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
            List{
                ForEach(ratings) { rating in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(rating.ratedSymptom?.name ?? "no symptom")
                            Spacer()
                            Text(rating.vas.formatted())
                        }
                        Text(rating.date.formatted()).font(.footnote)
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
            .toolbar {
                Button {
                    addRating()
                } label: {
                    Label("Rating", systemImage: "plus")
                }
            }
        }
        detail: {

            NavigationStack {
                
            }

        }

    }
    
    private func addRating() {
        let newRating = Rating(vas: 5.5, ratedSymptom: Symptom(name: "Sample symptom", type: "Symptom", creatingDevice: "Smaple device"))
        modelContext.insert(newRating)
    }
}

#Preview {
    RatingsListView()
}
