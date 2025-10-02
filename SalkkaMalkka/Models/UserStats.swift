//
//  UserStats.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import Foundation

/// 사용자 통계 모델
struct UserStats: Codable {
    var totalSavedAmount: Int = 0
    var monthlySavedAmount: Int = 0
    var totalPurchasedAmount: Int = 0
    var monthlyPurchasedAmount: Int = 0
    var preventionRate: Double = 0.0
    var consecutiveDays: Int = 0
    var lastUpdated: Date = Date()

    /// 이번 달 절약 금액 계산
    mutating func updateMonthlySaved(from items: [WishItem]) {
        let calendar = Calendar.current
        let thisMonth = calendar.component(.month, from: Date())
        let thisYear = calendar.component(.year, from: Date())

        monthlySavedAmount = items
            .filter { item in
                item.status == .abandoned &&
                calendar.component(.month, from: item.createdAt) == thisMonth &&
                calendar.component(.year, from: item.createdAt) == thisYear
            }
            .reduce(0) { $0 + $1.price }
    }

    /// 이번 달 구매 금액 계산
    mutating func updateMonthlyPurchased(from items: [WishItem]) {
        let calendar = Calendar.current
        let thisMonth = calendar.component(.month, from: Date())
        let thisYear = calendar.component(.year, from: Date())

        monthlyPurchasedAmount = items
            .filter { item in
                item.status == .purchased &&
                calendar.component(.month, from: item.createdAt) == thisMonth &&
                calendar.component(.year, from: item.createdAt) == thisYear
            }
            .reduce(0) { $0 + $1.price }
    }

    /// 총 절약 금액 계산
    mutating func updateTotalSaved(from items: [WishItem]) {
        totalSavedAmount = items
            .filter { $0.status == .abandoned }
            .reduce(0) { $0 + $1.price }
    }

    /// 총 구매 금액 계산
    mutating func updateTotalPurchased(from items: [WishItem]) {
        totalPurchasedAmount = items
            .filter { $0.status == .purchased }
            .reduce(0) { $0 + $1.price }
    }

    /// 충동구매 방지율 계산
    mutating func updatePreventionRate(from items: [WishItem]) {
        let completedItems = items.filter { $0.status != .waiting }
        guard !completedItems.isEmpty else {
            preventionRate = 0.0
            return
        }

        let abandonedCount = completedItems.filter { $0.status == .abandoned }.count
        preventionRate = Double(abandonedCount) / Double(completedItems.count) * 100.0
    }

    /// 모든 통계 업데이트
    mutating func updateAll(from items: [WishItem]) {
        updateMonthlySaved(from: items)
        updateMonthlyPurchased(from: items)
        updateTotalSaved(from: items)
        updateTotalPurchased(from: items)
        updatePreventionRate(from: items)
        lastUpdated = Date()
    }
}
