//
//  NotificationManager.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import Foundation
import UserNotifications

/// 로컬 푸시 알림 관리자
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// 알림 권한 요청
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// 7일 후 알림 스케줄링 (D-3, D-2, D-1, D-Day 매일 저녁 8시 알림)
    func scheduleNotification(for item: WishItem) {
        let calendar = Calendar.current

        // D-3부터 D-Day까지 알림 예약
        for daysOffset in -3...0 {
            guard let notificationDate = calendar.date(byAdding: .day, value: daysOffset, to: item.waitingUntil) else { continue }

            let content = UNMutableNotificationContent()

            if daysOffset == 0 {
                // D-Day
                content.title = "고민할 시간이 끝났어요!"
                content.body = "아직도 \(item.name)이(가) 필요한가요? (₩\(item.price.formatted()))"
            } else {
                // D-3, D-2, D-1
                let daysLeft = abs(daysOffset)
                content.title = "\(item.name)"
                content.body = "고민할 시간이 \(daysLeft)일 남았어요! (₩\(item.price.formatted()))"
            }

            content.sound = .default
            content.badge = 1
            content.userInfo = ["itemId": item.id.uuidString]

            // 저녁 8시(20:00)에 알림 발송 (사용자가 퇴근 후 확인하기 좋은 시간)
            var triggerDateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
            triggerDateComponents.hour = 20
            triggerDateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

            let identifier = "\(item.id.uuidString)-D\(daysOffset)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ 알림 스케줄링 실패 (D\(daysOffset)): \(error.localizedDescription)")
                } else {
                    print("✅ 알림 스케줄링 성공 (D\(daysOffset), 20:00): \(item.name)")
                }
            }
        }
    }

    /// 알림 취소 (D-3, D-2, D-1, D-Day 모두 취소)
    func cancelNotification(for item: WishItem) {
        var identifiers: [String] = []
        for daysOffset in -3...0 {
            identifiers.append("\(item.id.uuidString)-D\(daysOffset)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ 알림 취소: \(item.name) (D-3 ~ D-Day)")
    }

    /// 모든 알림 취소
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// 대기 중인 알림 확인 (디버깅용)
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📬 대기 중인 알림: \(requests.count)개")
            for request in requests {
                print("  - \(request.identifier): \(request.content.body)")
            }
        }
    }
}
