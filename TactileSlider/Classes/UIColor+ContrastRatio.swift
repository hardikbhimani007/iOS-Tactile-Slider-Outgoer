//
//  UIColor+ContrastRatio.swift
//  TactileSlider
//
//  Created by Dale Price on 8/4/21 based on https://stackoverflow.com/questions/42355778/how-to-compute-color-contrast-ratio-between-two-uicolor-instances
//

import UIKit

public extension UIColor {

    /// Creates a color from a hex string such as `"#D478FF"`, `"D478FF"`, or `"#RRGGBBAA"`.
    convenience init?(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") {
            string.removeFirst()
        }
        guard string.count == 6 || string.count == 8 else {
            return nil
        }
        var value: UInt64 = 0
        guard Scanner(string: string).scanHexInt64(&value) else {
            return nil
        }
        let hasAlpha = string.count == 8
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
        if hasAlpha {
            r = CGFloat((value & 0xFF00_0000) >> 24) / 255
            g = CGFloat((value & 0x00FF_0000) >> 16) / 255
            b = CGFloat((value & 0x0000_FF00) >> 8) / 255
            a = CGFloat(value & 0x0000_00FF) / 255
        } else {
            r = CGFloat((value & 0xFF0000) >> 16) / 255
            g = CGFloat((value & 0x00FF00) >> 8) / 255
            b = CGFloat(value & 0x0000FF) / 255
            a = 1
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

internal extension UIColor {
    
    static func contrastRatio(between color1: UIColor, and color2: UIColor) -> CGFloat {
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
        
        let luminance1 = color1.luminance()
        let luminance2 = color2.luminance()
        
        let luminanceDarker = min(luminance1, luminance2)
        let luminanceLighter = max(luminance1, luminance2)
        
        return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
    }
    
    func contrastRatio(with color: UIColor) -> CGFloat {
        return UIColor.contrastRatio(between: self, and: color)
    }
    
    func luminance() -> CGFloat {
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
        
        let ciColor = CIColor(color: self)
        
        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }
        
        return 0.2126 * adjust(colorComponent: ciColor.red) + 0.7152 * adjust(colorComponent: ciColor.green) + 0.0722 * adjust(colorComponent: ciColor.blue)
    }
}
