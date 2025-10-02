//
//  StatsView.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: WishListViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 이번 달 절약 금액
                StatCard(
                    title: "이번 달 절약 금액",
                    value: viewModel.monthlySaved.currencyFormatted(),
                    color: .mintGreen,
                    icon: "sparkles"
                )

                // 총 누적 절약 금액
                StatCard(
                    title: "총 누적 절약 금액",
                    value: viewModel.totalSaved.currencyFormatted(),
                    color: .oceanBlue,
                    icon: "banknote"
                )

                // 충동구매 방지율
                StatCard(
                    title: "충동구매 방지율",
                    value: String(format: "%.1f%%", viewModel.preventionRate),
                    color: .green,
                    icon: "chart.line.uptrend.xyaxis"
                )

                // 대기 중인 금액
                StatCard(
                    title: "대기 중인 금액",
                    value: viewModel.totalWaitingAmount.currencyFormatted(),
                    color: .orange,
                    icon: "hourglass"
                )

                // 완료된 아이템 목록
                if !viewModel.completedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("최근 결정한 물건들")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(viewModel.completedItems.prefix(10)) { item in
                            CompletedItemRow(item: item)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("절약 통계")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}

// MARK: - Completed Item Row

struct CompletedItemRow: View {
    let item: WishItem

    var body: some View {
        HStack(spacing: 12) {
            // 상태 아이콘
            Circle()
                .fill(item.status.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(item.price.currencyFormatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(item.status.emoji)
                .font(.title3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}
