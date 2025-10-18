//
//  ContentView.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WishListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // 메인 컨텐츠
                VStack(spacing: 0) {
                    // 헤더: 이번 달 절약 금액
                    SavingsHeaderView(amount: viewModel.monthlySaved)
                        .padding(.top)

                    // 위시리스트
                    if viewModel.waitingItems.isEmpty {
                        EmptyStateView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.waitingItems) { item in
                                    WishItemRow(item: item) {
                                        viewModel.selectItem(item)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }

                    Spacer()
                }

                // 플로팅 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showAddSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.mintGreen)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("살까말까")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: HStack(spacing: 16) {
                // 통계 버튼
                NavigationLink(destination: StatsView(viewModel: viewModel)) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.mintGreen)
                }

                // 설정 버튼
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.mintGreen)
                }
            })
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddWishItemView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showDecisionSheet) {
                if let item = viewModel.selectedItem {
                    DecisionView(item: item, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView(isPresented: $viewModel.showPaywall)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    subscriptionBadge
                }
            }
        }
    }

    // MARK: - Subscription Badge

    private var subscriptionBadge: some View {
        HStack(spacing: 6) {
            if viewModel.isPremium {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("프리미엄")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.yellow)
            } else {
                Text(viewModel.slotsStatusText)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(viewModel.isPremium ? Color.yellow.opacity(0.1) : Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Savings Header

struct SavingsHeaderView: View {
    let amount: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("이번 달 절약 금액")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(amount.currencyFormatted())
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.mintGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("아직 등록된 물건이 없어요")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("+ 버튼을 눌러 사고 싶은 물건을 등록해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Wish Item Row

struct WishItemRow: View {
    let item: WishItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 이미지
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }

                // 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(item.price.currencyFormatted())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    if let memo = item.memo {
                        Text(memo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // 타이머 및 프로그레스
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("D-\(item.daysRemaining)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(item.daysRemaining <= 1 ? .coral : .orange)

                        Text("⏳")
                            .font(.title3)
                    }

                    // 프로그레스 바
                    ProgressView(value: item.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .mintGreen))
                        .frame(width: 60)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
