//
//  StoreKitManager.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-18.
//

import StoreKit
import SwiftUI

/// StoreKit 2 기반 구독 관리자
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    // MARK: - Published Properties

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .free

    // MARK: - Product IDs

    private let productIDs: Set<String> = ["premium_monthly_3990"]

    // MARK: - Transaction Listener

    private var transactionListener: Task<Void, Never>?

    // MARK: - Initialization

    private init() {
        // Transaction 업데이트 리스너 시작
        transactionListener = observeTransactionUpdates()

        // 초기 상태 로드
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    /// App Store Connect에서 제품 정보 로드
    func loadProducts() async {
        do {
            print("🛒 Loading products from App Store...")
            let storeProducts = try await Product.products(for: productIDs)
            products = storeProducts.sorted { $0.price < $1.price }

            print("✅ Loaded \(products.count) products")
            for product in products {
                print("  - \(product.displayName): \(product.displayPrice)")
            }
        } catch {
            print("❌ Failed to load products: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    /// 제품 구매
    func purchase(_ product: Product) async throws -> Transaction? {
        print("💳 Attempting to purchase: \(product.displayName)")

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // 거래 검증
            let transaction = try checkVerified(verification)

            print("✅ Purchase successful: \(transaction.productID)")

            // 구독 상태 업데이트
            await updateSubscriptionStatus()

            // 거래 완료 처리
            await transaction.finish()

            return transaction

        case .userCancelled:
            print("⚠️ User cancelled purchase")
            return nil

        case .pending:
            print("⏳ Purchase pending (e.g., Ask to Buy)")
            return nil

        @unknown default:
            print("❌ Unknown purchase result")
            return nil
        }
    }

    // MARK: - Restore Purchases

    /// 구매 복원
    func restorePurchases() async {
        print("🔄 Restoring purchases...")

        do {
            // AppStore.sync()로 최신 거래 동기화
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("✅ Purchases restored successfully")
        } catch {
            print("❌ Failed to restore purchases: \(error.localizedDescription)")
        }
    }

    // MARK: - Subscription Status

    /// 현재 구독 상태 업데이트
    func updateSubscriptionStatus() async {
        print("🔍 Checking subscription status...")

        var hasPremium = false
        var latestTransaction: Transaction?

        // 현재 활성 구독 확인
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // premium_monthly_3990 확인
                if transaction.productID == "premium_monthly_3990" {
                    hasPremium = true
                    latestTransaction = transaction
                    purchasedProductIDs.insert(transaction.productID)

                    print("✅ Active subscription found: \(transaction.productID)")
                    if let expiry = transaction.expirationDate {
                        print("   Expires: \(expiry)")
                    }
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }

        // 구독 상태 업데이트
        if hasPremium, let transaction = latestTransaction {
            subscriptionStatus = SubscriptionStatus(
                tier: .premium,
                isActive: true,
                expiresAt: transaction.expirationDate,
                purchasedAt: transaction.purchaseDate
            )
            print("✅ Subscription active: Premium")
        } else {
            subscriptionStatus = .free
            purchasedProductIDs.removeAll()
            print("ℹ️ No active subscription - Free tier")
        }
    }

    // MARK: - Transaction Observer

    /// 거래 업데이트 모니터링
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }

                do {
                    let transaction = try self.checkVerified(result)

                    print("🔔 Transaction update: \(transaction.productID)")

                    // 구독 상태 업데이트
                    await self.updateSubscriptionStatus()

                    // 거래 완료
                    await transaction.finish()
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    /// 거래 검증 (JWS 서명 확인)
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("❌ Transaction verification failed")
            throw StoreError.failedVerification

        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Subscription Management

    /// 구독 관리 페이지 열기
    func openSubscriptionManagement() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task {
                do {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                } catch {
                    print("❌ Failed to open subscription management: \(error)")
                }
            }
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed

    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "거래 검증에 실패했습니다."
        case .productNotFound:
            return "상품을 찾을 수 없습니다."
        case .purchaseFailed:
            return "구매에 실패했습니다."
        }
    }
}
