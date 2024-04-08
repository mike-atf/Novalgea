//
//  Extension String.swift
//  Novalgea
//
//  Created by aDev on 22/03/2024.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

extension String {
   func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
