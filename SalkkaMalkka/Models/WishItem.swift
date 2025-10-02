//
//  WishItem.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import Foundation
import SwiftUI

/// 위시리스트 아이템 모델
struct WishItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var price: Int
    var purchaseURL: String?
    var memo: String?
    var imageData: Data?
    var createdAt: Date
    var waitingUntil: Date
    var status: WishItemStatus
    var extensionCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        price: Int,
        purchaseURL: String? = nil,
        memo: String? = nil,
        imageData: Data? = nil,
        createdAt: Date = Date(),
        waitingDays: Int = 7
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.purchaseURL = purchaseURL
        self.memo = memo
        self.imageData = imageData
        self.createdAt = createdAt
        self.waitingUntil = Calendar.current.date(byAdding: .day, value: waitingDays, to: createdAt) ?? createdAt
        self.status = .waiting
        self.extensionCount = 0
    }

    /// 남은 일수 계산
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: waitingUntil)
        return max(0, components.day ?? 0)
    }

    /// 대기 완료 여부
    var isWaitingComplete: Bool {
        return Date() >= waitingUntil && status == .waiting
    }

    /// 프로그레스 바 진행률 (0.0 ~ 1.0)
    var progress: Double {
        let totalDuration = waitingUntil.timeIntervalSince(createdAt)
        let elapsed = Date().timeIntervalSince(createdAt)
        return min(1.0, max(0.0, elapsed / totalDuration))
    }

    /// 7일 연장 (최대 3회)
    mutating func extend() -> Bool {
        guard extensionCount < 3 else { return false }
        waitingUntil = Calendar.current.date(byAdding: .day, value: 7, to: waitingUntil) ?? waitingUntil
        extensionCount += 1
        return true
    }

    /// 구매 완료 처리
    mutating func markAsPurchased() {
        status = .purchased
    }

    /// 구매 포기 처리
    mutating func markAsAbandoned() {
        status = .abandoned
    }
}

/// 위시 아이템 상태
enum WishItemStatus: String, Codable {
    case waiting = "대기중"
    case purchased = "구매완료"
    case abandoned = "포기"

    var color: Color {
        switch self {
        case .waiting:
            return .orange
        case .purchased:
            return .red
        case .abandoned:
            return .green
        }
    }

    var emoji: String {
        switch self {
        case .waiting:
            return "⏳"
        case .purchased:
            return "💸"
        case .abandoned:
            return "✅"
        }
    }
}
