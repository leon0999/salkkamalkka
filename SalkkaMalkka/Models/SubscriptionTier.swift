//
//  SubscriptionTier.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-18.
//

import Foundation

/// 구독 티어 (무료 vs 프리미엄)
enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case premium = "premium_monthly_3990"

    /// 최대 위시 아이템 개수
    var maxWishItems: Int {
        switch self {
        case .free:
            return 3
        case .premium:
            return Int.max
        }
    }

    /// 표시 이름
    var displayName: String {
        switch self {
        case .free:
            return "무료"
        case .premium:
            return "프리미엄"
        }
    }

    /// 가격 표시
    var priceText: String {
        switch self {
        case .free:
            return "무료"
        case .premium:
            return "₩3,990/월"
        }
    }

    /// 프리미엄 기능 목록
    var features: [String] {
        switch self {
        case .free:
            return [
                "상품 최대 3개 등록",
                "기본 통계",
                "기본 알림"
            ]
        case .premium:
            return [
                "상품 무제한 등록",
                "상세 통계 분석",
                "커스텀 알림",
                "iCloud 백업",
                "광고 제거",
                "프리미엄 배지"
            ]
        }
    }

    /// StoreKit Product ID
    var productID: String? {
        switch self {
        case .free:
            return nil
        case .premium:
            return "premium_monthly_3990"
        }
    }
}

/// 구독 상태
struct SubscriptionStatus: Codable {
    var tier: SubscriptionTier
    var isActive: Bool
    var expiresAt: Date?
    var purchasedAt: Date?

    /// 기본 무료 상태
    static var free: SubscriptionStatus {
        SubscriptionStatus(
            tier: .free,
            isActive: false,
            expiresAt: nil,
            purchasedAt: nil
        )
    }

    /// 프리미엄 활성 여부
    var isPremium: Bool {
        return tier == .premium && isActive
    }

    /// 만료 여부 체크
    var isExpired: Bool {
        guard let expiry = expiresAt else { return false }
        return Date() > expiry
    }

    /// 남은 일수
    var daysRemaining: Int? {
        guard let expiry = expiresAt, !isExpired else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiry)
        return components.day
    }
}
