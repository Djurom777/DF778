import SwiftUI

extension Font {
    // Title Fonts
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body Fonts
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodyBold = Font.system(size: 16, weight: .semibold, design: .rounded)
    
    // Small Fonts
    static let caption1 = Font.system(size: 12, weight: .medium, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    
    // Button Font
    static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
}