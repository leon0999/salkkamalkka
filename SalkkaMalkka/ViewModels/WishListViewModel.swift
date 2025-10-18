//
//  WishListViewModel.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import Foundation
import Combine
import SwiftUI

/// 위시리스트 ViewModel
class WishListViewModel: ObservableObject {
    @Published var wishItems: [WishItem] = []
    @Published var userStats: UserStats = UserStats()
    @Published var showAddSheet: Bool = false
    @Published var showDecisionSheet: Bool = false
    @Published var selectedItem: WishItem?
    @Published var showPaywall: Bool = false // 🔥 Paywall 표시

    private var dataManager = DataManager.shared
    private var storeManager = StoreKitManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // DataManager의 데이터를 구독
        dataManager.$wishItems
            .assign(to: &$wishItems)

        dataManager.$userStats
            .assign(to: &$userStats)

        // 알림 권한 요청
        NotificationManager.shared.requestAuthorization { granted in
            print(granted ? "✅ 알림 권한 허용됨" : "❌ 알림 권한 거부됨")
        }
    }

    // MARK: - Actions

    func addWishItem(name: String, price: Int, url: String?, memo: String?, imageData: Data?) {
        // 🔥 상품 등록 제한 체크
        guard canAddWishItem else {
            print("⚠️ Cannot add more items - showing paywall")
            showPaywall = true
            return
        }

        let item = WishItem(
            name: name,
            price: price,
            purchaseURL: url,
            memo: memo,
            imageData: imageData
        )
        dataManager.addWishItem(item)
    }

    func deleteItem(_ item: WishItem) {
        dataManager.deleteWishItem(item)
    }

    func markAsPurchased(_ item: WishItem) {
        dataManager.markAsPurchased(item)
        showDecisionSheet = false
    }

    func markAsAbandoned(_ item: WishItem) {
        dataManager.markAsAbandoned(item)
        showDecisionSheet = false
    }

    func extendWaitingPeriod(_ item: WishItem) {
        if dataManager.extendWaitingPeriod(item) {
            showDecisionSheet = false
        }
    }

    func selectItem(_ item: WishItem) {
        selectedItem = item
        showDecisionSheet = true
    }

    // MARK: - Computed Properties

    var waitingItems: [WishItem] {
        dataManager.waitingItems
    }

    var completedItems: [WishItem] {
        dataManager.completedItems
    }

    var readyToDecideItems: [WishItem] {
        dataManager.readyToDecideItems
    }

    var totalWaitingAmount: Int {
        dataManager.totalWaitingAmount
    }

    var monthlySaved: Int {
        userStats.monthlySavedAmount
    }

    var totalSaved: Int {
        userStats.totalSavedAmount
    }

    var preventionRate: Double {
        userStats.preventionRate
    }

    // MARK: - Subscription Status

    /// 현재 구독 티어
    var currentTier: SubscriptionTier {
        storeManager.subscriptionStatus.tier
    }

    /// 프리미엄 여부
    var isPremium: Bool {
        storeManager.subscriptionStatus.isPremium
    }

    /// 상품 추가 가능 여부
    var canAddWishItem: Bool {
        let currentCount = waitingItems.count
        let maxCount = currentTier.maxWishItems

        print("📊 Current items: \(currentCount)/\(maxCount == Int.max ? "∞" : "\(maxCount)")")

        return currentCount < maxCount
    }

    /// 남은 슬롯 개수
    var remainingSlots: Int {
        let currentCount = waitingItems.count
        let maxCount = currentTier.maxWishItems

        if maxCount == Int.max {
            return Int.max
        }

        return max(0, maxCount - currentCount)
    }

    /// 슬롯 상태 텍스트
    var slotsStatusText: String {
        if isPremium {
            return "무제한"
        } else {
            return "\(remainingSlots)/3 남음"
        }
    }
}
