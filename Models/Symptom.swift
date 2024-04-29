//
//  Symptom.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import SwiftData


@Model final class Symptom: Identifiable, Equatable, Hashable  {
    
    var name: String = "Default symptom"
    var type: String = "Symptom" // the other option is Side effect
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var averages: [Double]?
    var creatingDevice: String = "Device"
    var maxVAS: Double = 10.0
    var minVAS: Double = 0.0
//    var colorModel: [CGFloat]?
    var colorName: String? // as key in ColorScheme.symptomsColors dictionary
    var uuid: UUID = UUID()
    
    var diaryEvents: [DiaryEvent]?
    @Relationship(deleteRule: .cascade, inverse: \Rating.ratedSymptom) var ratingEvents: [Rating]?
    var treatingMeds: [Medicine]? // optional to-many relationShips not supported in @Query #Predicate
    var causingMeds: [Medicine]? // optional to-many relationShips not supported in @Query #Predicate
    var isSideEffect: Bool = false // because of the above limitation
    
    init(name: String, type: String ,averages: [Double]? = nil, creatingDevice: String?=nil, maxVAS: Double = 10, minVAS: Double = 0, diaryEvents: [DiaryEvent]? = [], ratingEvents: [Rating]? = [], treatingMeds: [Medicine]? = [], causingMeds: [Medicine]? = [], isSideEffect: Bool?=false, color: Color?=nil, colorName: String?=nil) {
        
        self.averages = averages
        self.type = type
        self.creatingDevice = creatingDevice ?? UIDevice.current.name
        self.maxVAS = maxVAS
        self.minVAS = minVAS
        self.name = name
        self.diaryEvents = diaryEvents
        self.ratingEvents = ratingEvents
        self.treatingMeds = treatingMeds
        self.causingMeds = causingMeds
        if causingMeds?.count ?? 0 > 0 { self.isSideEffect = true }
        if isSideEffect != nil { self.isSideEffect = isSideEffect! }
        
        if colorName != nil {
            self.colorName = colorName!
        } else {
            for key in ColorScheme.symptomColors.keys {
                if color == ColorScheme.symptomColors[key] {
                    self.colorName = key
                }
            }
        }
    }
    
    static func == (lhs: Symptom, rhs: Symptom) -> Bool {
        
        if lhs.uuid != rhs.uuid { return false }
        return true
        
    }
    
    public func ratingAverage(from: Date, to: Date) -> Double? {
        guard let ratings = ratingEvents else { return nil }
        
        let inDateRatings = ratings.filter { rating in
            if rating.date < from { return false }
            else if rating.date > to { return false }
            else { return true }
        }
        
        guard inDateRatings.count > 0 else { return nil }
        
        return inDateRatings.compactMap { $0.vas }.reduce(0, +) / Double(inDateRatings.count)
    }
    
    public func ratingsCount(from: Date, to: Date) -> Int {
        guard let ratings = ratingEvents else { return 0 }
        
        let inDateRatings = ratings.filter { rating in
            if rating.date < from { return false }
            else if rating.date > to { return false }
            else { return true }
        }
        
        return inDateRatings.count
        
    }
    
    public func color() -> Color {
        
        guard let colorName else { return Color.primary }
        
        return Color(UIColor(named: colorName) ?? UIColor.label)
    }
    
    public func setNewColor(color: Color) {
        
        for key in ColorScheme.symptomColors.keys {
            if color == ColorScheme.symptomColors[key] {
                self.colorName = key
            }
        }        
    }

}


extension Symptom {
    
    static var preview: Symptom {
        
            Symptom(name: "Sample symptom", type: "Symptom", creatingDevice: "Sample device")
            
    }
    
    static var placeholder: Symptom {
        Symptom(name: UserText.term("Default"), type: "Symptom", creatingDevice: "-")

    }

}
