//
//  SettingsView.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-18.
//

import SwiftUI
import StoreKit

/// 설정 화면 - 구독 관리 및 앱 설정
struct SettingsView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        NavigationView {
            List {
                // 구독 정보 섹션
                subscriptionSection

                // 앱 정보 섹션
                appInfoSection

                // 지원 섹션
                supportSection
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("구매 복원", isPresented: $showRestoreAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        Section {
            // 현재 구독 상태
            currentSubscriptionCard

            // 구독 관리 버튼들
            if storeManager.subscriptionStatus.isPremium {
                premiumUserButtons
            } else {
                freeUserButtons
            }

        } header: {
            Text("구독 관리")
        } footer: {
            if let expiry = storeManager.subscriptionStatus.expiresAt {
                Text("다음 결제일: \(expiry.formatted(date: .long, time: .omitted))")
                    .font(.caption)
            }
        }
    }

    // MARK: - Current Subscription Card

    private var currentSubscriptionCard: some View {
        VStack(spacing: 12) {
            // 아이콘 및 티어 이름
            HStack(spacing: 12) {
                Image(systemName: storeManager.subscriptionStatus.isPremium ? "crown.fill" : "star")
                    .font(.system(size: 40))
                    .foregroundColor(storeManager.subscriptionStatus.isPremium ? .yellow : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(storeManager.subscriptionStatus.tier.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(storeManager.subscriptionStatus.isPremium ? "모든 기능 이용 가능" : "상품 최대 3개까지")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // 프리미엄 상태 배지
            if storeManager.subscriptionStatus.isPremium {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("활성 상태")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    if let days = storeManager.subscriptionStatus.daysRemaining {
                        Text("\(days)일 남음")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    // MARK: - Premium User Buttons

    private var premiumUserButtons: some View {
        Group {
            // App Store 구독 관리
            Button {
                storeManager.openSubscriptionManagement()
            } label: {
                HStack {
                    Image(systemName: "gear")
                        .foregroundColor(.blue)
                    Text("구독 관리")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 구매 복원
            Button {
                Task {
                    await restorePurchases()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                    Text("구매 복원")
                    Spacer()
                }
            }
        }
    }

    // MARK: - Free User Buttons

    private var freeUserButtons: some View {
        Group {
            // 프리미엄 업그레이드
            NavigationLink(destination: PaywallView(isPresented: .constant(true))) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("프리미엄 업그레이드")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }

            // 구매 복원
            Button {
                Task {
                    await restorePurchases()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                    Text("구매 복원")
                    Spacer()
                }
            }
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section {
            // 버전 정보
            HStack {
                Text("버전")
                Spacer()
                Text(appVersion)
                    .foregroundColor(.secondary)
            }

            // 빌드 번호
            HStack {
                Text("빌드")
                Spacer()
                Text(buildNumber)
                    .foregroundColor(.secondary)
            }

        } header: {
            Text("앱 정보")
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        Section {
            // 이용약관
            Link(destination: URL(string: "https://example.com/terms")!) {
                HStack {
                    Text("이용약관")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 개인정보처리방침
            Link(destination: URL(string: "https://example.com/privacy")!) {
                HStack {
                    Text("개인정보처리방침")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 문의하기
            Link(destination: URL(string: "mailto:support@salkkamalkka.com")!) {
                HStack {
                    Text("문의하기")
                    Spacer()
                    Image(systemName: "envelope")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

        } header: {
            Text("지원")
        }
    }

    // MARK: - Helper Properties

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Restore Purchases

    private func restorePurchases() async {
        await storeManager.restorePurchases()

        // 결과 메시지 표시
        if storeManager.subscriptionStatus.isPremium {
            restoreMessage = "프리미엄 구독이 복원되었습니다."
        } else {
            restoreMessage = "복원할 구매 내역이 없습니다."
        }

        showRestoreAlert = true
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
