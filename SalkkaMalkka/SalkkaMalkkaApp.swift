//
//  SalkkaMalkkaApp.swift
//  SalkkaMalkka
//
//  Created by Claude on 2025-10-02.
//

import SwiftUI

@main
struct SalkkaMalkkaApp: App {
    init() {
        // 다크모드 자동 지원 (추가 설정 불필요)
        // 알림 델리게이트 설정
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // 시스템 다크모드 따라감
        }
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // 앱이 foreground에 있을 때도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // 알림 탭했을 때 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let itemIdString = userInfo["itemId"] as? String,
           let itemId = UUID(uuidString: itemIdString) {
            // 해당 아이템을 찾아서 Decision 화면 표시
            if let item = DataManager.shared.wishItems.first(where: { $0.id == itemId }) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ShowDecisionView"),
                    object: nil,
                    userInfo: ["item": item]
                )
            }
        }

        completionHandler()
    }
}
