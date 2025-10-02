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

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // 타이틀
            VStack(spacing: 8) {
                Text("⏰ 7일이 지났어요!")
                    .font(.title2)
                    .fontWeight(.bold)

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
                // 구매하기
                Button(action: {
                    viewModel.markAsPurchased(item)
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

                // 7일 더 생각하기
                if item.extensionCount < 3 {
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
                } else {
                    Text("더 이상 연장할 수 없어요 (최대 3회)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
