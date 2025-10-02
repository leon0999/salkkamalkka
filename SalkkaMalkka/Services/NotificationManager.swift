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

    /// 7일 후 알림 스케줄링
    func scheduleNotification(for item: WishItem) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 7일이 지났어요!"
        content.body = "아직도 \(item.name)이(가) 필요한가요? (₩\(item.price.formatted()))"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["itemId": item.id.uuidString]

        // 대기 종료 시각에 알림 발송
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.waitingUntil)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 스케줄링 실패: \(error.localizedDescription)")
            } else {
                print("✅ 알림 스케줄링 성공: \(item.name) - \(item.waitingUntil)")
            }
        }
    }

    /// 알림 취소
    func cancelNotification(for item: WishItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        print("🗑️ 알림 취소: \(item.name)")
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
