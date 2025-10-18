//
//  PaywallView.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-18.
//

import SwiftUI
import StoreKit

/// 프리미엄 업그레이드 Paywall
struct PaywallView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Binding var isPresented: Bool
    @State private var isPurchasing = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // 헤더
                    headerSection

                    // 기능 비교
                    featuresSection

                    // 가격 및 구매 버튼
                    pricingSection

                    // 약관
                    legalSection
                }
                .padding()
            }
            .navigationTitle("프리미엄 업그레이드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        isPresented = false
                    }
                }
            }
        }
        .task {
            await storeManager.loadProducts()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.3), radius: 10)

            Text("무제한으로\n더 많이 절약하세요")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text("프리미엄으로 상품을 무제한 등록하고\n더 많은 충동구매를 방지하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("프리미엄 기능")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                FeatureRow(
                    icon: "infinity",
                    title: "상품 무제한 등록",
                    description: "무료는 3개, 프리미엄은 무제한",
                    color: .blue
                )

                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "상세 통계 분석",
                    description: "트렌드 및 패턴 분석",
                    color: .green
                )

                FeatureRow(
                    icon: "icloud.fill",
                    title: "iCloud 백업",
                    description: "자동 백업 및 복원",
                    color: .cyan
                )

                FeatureRow(
                    icon: "sparkles",
                    title: "광고 완전 제거",
                    description: "깔끔한 UI 경험",
                    color: .orange
                )

                FeatureRow(
                    icon: "star.fill",
                    title: "프리미엄 배지",
                    description: "앱 지원자 배지 획득",
                    color: .purple
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
    }

    // MARK: - Pricing

    private var pricingSection: some View {
        VStack(spacing: 20) {
            if let product = storeManager.products.first {
                VStack(spacing: 8) {
                    Text(product.displayPrice)
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text("월간 구독")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("첫 7일 무료 체험")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.1))
                        )
                }
                .padding()

                // 구매 버튼
                Button {
                    Task {
                        await purchaseProduct(product)
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "crown.fill")
                            Text("무료로 시작하기")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(isPurchasing)

                // 구독 복원
                Button {
                    Task {
                        await storeManager.restorePurchases()
                    }
                } label: {
                    Text("구매 복원")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)

            } else {
                ProgressView("상품 정보 로딩 중...")
                    .frame(height: 200)
            }
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("• 구독은 자동으로 갱신됩니다")
            Text("• 언제든지 App Store에서 취소 가능")
            Text("• 무료 체험 종료 후 요금이 청구됩니다")
        }
        .font(.caption2)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.top, 20)

        HStack(spacing: 20) {
            Button("이용약관") {
                // Open terms
            }

            Button("개인정보처리방침") {
                // Open privacy
            }
        }
        .font(.caption)
        .foregroundColor(.blue)
        .padding(.top, 8)
    }

    // MARK: - Purchase Action

    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true

        do {
            if let transaction = try await storeManager.purchase(product) {
                print("✅ Purchase successful: \(transaction.productID)")
                isPresented = false
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
        }

        isPurchasing = false
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView(isPresented: .constant(true))
}
