//
//  DecisionView.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import SwiftUI

struct DecisionView: View {
    let item: WishItem
    @ObservedObject var viewModel: WishListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPurchaseConfirmation = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 24) {
            // 상단 닫기 버튼
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.trailing)
            }
            .padding(.top, 8)

            Spacer()

            // 타이틀
            VStack(spacing: 8) {
                if item.daysRemaining > 0 {
                    Text("고민할 시간이 \(item.daysRemaining)일 남았어요")
                        .font(.title2)
                        .fontWeight(.bold)
                } else {
                    Text("고민할 시간이 끝났어요!")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Text("아직도 필요한가요?")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            // 아이템 정보
            VStack(spacing: 12) {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Text(item.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(item.price.currencyFormatted())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.mintGreen)

                if let memo = item.memo {
                    Text(memo)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)

            // 선택 버튼들
            VStack(spacing: 12) {
                // 구매하러 가기
                Button(action: {
                    if let urlString = item.purchaseURL, !urlString.isEmpty, let url = URL(string: urlString) {
                        // 링크 있으면 열기
                        UIApplication.shared.open(url)
                        // 잠시 후 구매 확인 Alert 표시
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showPurchaseConfirmation = true
                        }
                    } else {
                        // 링크 없으면 바로 구매 확인
                        showPurchaseConfirmation = true
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("구매할게요")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.coral)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                // 필요 없어요
                Button(action: {
                    viewModel.markAsAbandoned(item)
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("필요 없어요")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mintGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                // 7일 더 생각하기 (D-Day일 때만 표시)
                if item.daysRemaining == 0 && item.extensionCount < 3 {
                    Button(action: {
                        viewModel.extendWaitingPeriod(item)
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("7일 더 생각해볼게요 (\(3 - item.extensionCount)회 남음)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.oceanBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else if item.daysRemaining == 0 && item.extensionCount >= 3 {
                    Text("더 이상 연장할 수 없어요 (최대 3회)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 나중에 다시 생각할게요 (뒤로 가기)
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left.circle")
                        Text("나중에 다시 생각할게요")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .alert("정말 구매하셨나요?", isPresented: $showPurchaseConfirmation) {
            Button("네", role: .destructive) {
                viewModel.markAsPurchased(item)
            }
            Button("아니요", role: .cancel) {
                // 아무것도 안 함
            }
        } message: {
            Text("구매를 완료하셨다면 '네'를 선택해주세요.")
        }
        .onChange(of: scenePhase) { newPhase in
            // 앱으로 돌아왔을 때 (외부 링크에서 복귀)
            if newPhase == .active && item.purchaseURL != nil && !item.purchaseURL!.isEmpty {
                // 이미 1초 delay로 Alert가 예약되어 있음
            }
        }
    }
}
