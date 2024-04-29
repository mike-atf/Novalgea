//
//  ColorManager.swift
//  Novalgea
//
//  Created by aDev on 12/04/2024.
//

import SwiftUI
import SwiftData

@MainActor class ColorManager {
        
    class func getNewMedicineColor(container: ModelContainer) -> Color {
        
        let context = container.mainContext
        let fetchDescriptorS = FetchDescriptor<Medicine>()

        if let existingMeds = try? context.fetch(fetchDescriptorS) {
            let usedColorsArray = existingMeds.compactMap { $0.color() }
            
            var usedColors = Set<Color>()
            for color in usedColorsArray {
                usedColors.insert(color)
            }
                            
            for mColor in ColorScheme.medicineColorsArray {
                if !usedColors.contains(mColor) {
                    return mColor
                }
            }
        }
        return ColorScheme.medicineColorsArray.first!

    }
    
    class func getNewCategoryColor(container: ModelContainer) -> Color {
        
        let context = container.mainContext
        let fetchDescriptorS = FetchDescriptor<EventCategory>()

        if let existingCategories = try? context.fetch(fetchDescriptorS) {
            let usedColorsArray = existingCategories.compactMap { $0.color() }
            
            var usedColors = Set<Color>()
            for color in usedColorsArray {
                usedColors.insert(color)
            }
            for eColor in ColorScheme.eventCategoryColorsArray {
                if !usedColors.contains(eColor) {
                    return  eColor

                }
            }
        }
        return ColorScheme.eventCategoryColorsArray.first!

    }
    
    class func getNewSymptomColor(container: ModelContainer) -> Color {
        
        let context = container.mainContext
        let fetchDescriptorS = FetchDescriptor<Symptom>()

        if let existingCategories = try? context.fetch(fetchDescriptorS) {
            let usedColorsArray = existingCategories.compactMap { $0.color() }
            
            var usedColors = Set<Color>()
            for color in usedColorsArray {
                usedColors.insert(color)
            }
            for eColor in ColorScheme.symptomColorsArray {
                if !usedColors.contains(eColor) {
                    return  eColor
                }
            }
        }
        return ColorScheme.symptomColorsArray.first!

    }

    
//    class func getColor(object: Any, container: ModelContainer) -> Color {
//        
//        let context = container.mainContext
//        
//        if object is Medicine {
//                        
//            let fetchDescriptorS = FetchDescriptor<Medicine>()
//
//            if let existingMeds = try? context.fetch(fetchDescriptorS) {
//                let usedColorsArray = existingMeds.compactMap { $0.color() }
//                
//                var usedColors = Set<Color>()
//                for color in usedColorsArray {
//                    usedColors.insert(color)
//                }
//                                
//                for mColor in ColorScheme.medicineColorsArray {
//                    if !usedColors.contains(mColor) {
//                        return mColor
//                    }
//                }
//            }
//            return ColorScheme.medicineColorsArray.first!
//        }
//        else if object is Symptom {
//        
//            let fetchDescriptorS = FetchDescriptor<Symptom>()
//
//            if let existingSymptoms = try? context.fetch(fetchDescriptorS) {
//                let usedColorsArray = existingSymptoms.compactMap { $0.color() }
//                
//                var usedColors = Set<Color>()
//                for color in usedColorsArray {
//                    usedColors.insert(color)
//                }
//                for sColor in ColorScheme.symptomColorsArray {
//                    if !usedColors.contains(sColor) {
//                        return sColor
//                    }
//                }
//                
//            }
//            return ColorScheme.symptomColorsArray.first!
//        }
//        else if object is EventCategory {
//        
//            let fetchDescriptorS = FetchDescriptor<EventCategory>()
//
//            if let existingCategories = try? context.fetch(fetchDescriptorS) {
//                let usedColorsArray = existingCategories.compactMap { $0.color() }
//                
//                var usedColors = Set<Color>()
//                for color in usedColorsArray {
//                    usedColors.insert(color)
//                }
//                for eColor in ColorScheme.eventCategoryColorsArray {
//                    if !usedColors.contains(eColor) {
//                        return eColor
//                    }
//                }
//                
//            }
//            return ColorScheme.eventCategoryColorsArray.first!
//        } else {
//            let ierror = InternalError(file: "ColorManager", function: "getColor", appError: "unrecognised entity \(object) requesting display color")
//            ErrorManager.addError(error: ierror, container: container)
//        }
//
//        return ColorScheme.medicineColorsArray.first!
//
//    }
    
//    class func modelFromColor(color: Color) -> [CGFloat] {
//        return UIColor(color).cgColor.components!
////        return [uic.com, uic.green, uic.blue, uic.alpha]
//    }
    
//    class func colorFromModel(model: [CGFloat]) -> Color {
//        guard model.count == 4 else { return Color.primary }
//        return Color(.sRGB,red: model[0], green: model[1], blue: model[2])
////        return Color(UIColor(displayP3Red: model.red, green: model.green, blue: model.blue, alpha: model.alpha))
//    }

}
