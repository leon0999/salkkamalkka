//
//  DataManager.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import Foundation
import Combine

/// 데이터 관리 서비스 (UserDefaults 기반)
class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var wishItems: [WishItem] = []
    @Published var userStats: UserStats = UserStats()

    private let wishItemsKey = "wishItems"
    private let userStatsKey = "userStats"

    init() {
        loadData()
    }

    // MARK: - Load & Save

    func loadData() {
        loadWishItems()
        loadUserStats()
        updateStats()
    }

    private func loadWishItems() {
        if let data = UserDefaults.standard.data(forKey: wishItemsKey),
           let items = try? JSONDecoder().decode([WishItem].self, from: data) {
            wishItems = items
        }
    }

    private func loadUserStats() {
        if let data = UserDefaults.standard.data(forKey: userStatsKey),
           let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = stats
        }
    }

    private func saveWishItems() {
        if let data = try? JSONEncoder().encode(wishItems) {
            UserDefaults.standard.set(data, forKey: wishItemsKey)
        }
    }

    private func saveUserStats() {
        if let data = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(data, forKey: userStatsKey)
        }
    }

    // MARK: - CRUD Operations

    func addWishItem(_ item: WishItem) {
        wishItems.append(item)
        saveWishItems()
        updateStats()

        // 7일 후 알림 스케줄링
        NotificationManager.shared.scheduleNotification(for: item)
    }

    func updateWishItem(_ item: WishItem) {
        if let index = wishItems.firstIndex(where: { $0.id == item.id }) {
            wishItems[index] = item
            saveWishItems()
            updateStats()
        }
    }

    func deleteWishItem(_ item: WishItem) {
        wishItems.removeAll { $0.id == item.id }
        saveWishItems()
        updateStats()

        // 알림 취소
        NotificationManager.shared.cancelNotification(for: item)
    }

    func markAsPurchased(_ item: WishItem) {
        if let index = wishItems.firstIndex(where: { $0.id == item.id }) {
            wishItems[index].markAsPurchased()
            saveWishItems()
            updateStats()

            NotificationManager.shared.cancelNotification(for: item)
        }
    }

    func markAsAbandoned(_ item: WishItem) {
        if let index = wishItems.firstIndex(where: { $0.id == item.id }) {
            wishItems[index].markAsAbandoned()
            saveWishItems()
            updateStats()

            NotificationManager.shared.cancelNotification(for: item)
        }
    }

    func extendWaitingPeriod(_ item: WishItem) -> Bool {
        if let index = wishItems.firstIndex(where: { $0.id == item.id }) {
            let success = wishItems[index].extend()
            if success {
                saveWishItems()

                // 새로운 날짜로 알림 재스케줄링
                NotificationManager.shared.cancelNotification(for: item)
                NotificationManager.shared.scheduleNotification(for: wishItems[index])
            }
            return success
        }
        return false
    }

    // MARK: - Statistics

    func updateStats() {
        userStats.updateAll(from: wishItems)
        saveUserStats()
    }

    // MARK: - Queries

    var waitingItems: [WishItem] {
        wishItems.filter { $0.status == .waiting }.sorted { $0.waitingUntil < $1.waitingUntil }
    }

    var completedItems: [WishItem] {
        wishItems.filter { $0.status != .waiting }.sorted { $0.createdAt > $1.createdAt }
    }

    var readyToDecideItems: [WishItem] {
        wishItems.filter { $0.isWaitingComplete }
    }

    var totalWaitingAmount: Int {
        waitingItems.reduce(0) { $0 + $1.price }
    }
}
