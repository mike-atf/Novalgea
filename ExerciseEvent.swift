//
//  ExerciseEvent.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model class ExerciseEvent: Identifiable  {
    var endDate: Date?
    var exerciseName: String = "Exercise"
    var startDate: Date = Date()
    var unit: String = "Unit"
    var uuid: UUID = UUID()
    var value: Double = 0.0
    
    @Relationship(inverse: \Rating.relatedExerciseEvents) var relatedRatings: [Rating]?
    
    public init(exercise: String, date: Date?, unit: String, value: Double) {
        self.exerciseName = exercise
        self.startDate = date ?? .now
        self.unit = unit
        self.value = value
    }
    
}

extension ExerciseEvent {
    
    static var preview: ExerciseEvent {
        ExerciseEvent(exercise: "Default exercise", date: .now.addingTimeInterval(-TimeInterval.random(in: 0...30*24*3600)), unit: "miles", value: Double.random(in: 0...5))
    }

}
