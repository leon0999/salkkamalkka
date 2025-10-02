//
//  Extensions.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import Foundation
import SwiftUI

// MARK: - Int Extensions

extension Int {
    /// 원화 포맷 (예: 15,000)
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    /// 원화 포맷 with 원 (예: ₩15,000)
    func currencyFormatted() -> String {
        return "₩" + formatted()
    }
}

// MARK: - Color Extensions

extension Color {
    static let mintGreen = Color(hex: "#00D9B2")
    static let coral = Color(hex: "#FF6B6B")
    static let oceanBlue = Color(hex: "#4A90E2")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extensions

extension Date {
    /// "2025년 10월 2일" 형식
    func koreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: self)
    }

    /// "10/02 14:30" 형식
    func shortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: self)
    }
}
