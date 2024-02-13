//
//  ErrorDatesView.swift
//  Novalgea
//
//  Created by aDev on 13/02/2024.
//

import SwiftUI

struct ErrorDatesView: View {
    
    var dates: [Date]
    
    var body: some View {
        
        List(dates, id: \.self) { date in
            Text(date.formatted())
        }
        .navigationTitle("Dates")
    }
}

#Preview {
    ErrorDatesView(dates: [Date.now, Date.now.addingTimeInterval(-24*3600)])
}
