//
//  DailyNotification.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/09/22.
//

import Foundation
import UserNotifications
import UIKit

enum LocalNotifyID {
    static let daily10 = "daily10_color_check"
}

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    private override init() {}

    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            print("Notification permission:", granted, err?.localizedDescription ?? "")
            if granted {
                self.scheduleDaily10AM()
            }
        }
    }

    func scheduleDaily10AM() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [LocalNotifyID.daily10])

        let content = UNMutableNotificationContent()
        content.title = "今日の色を確認しよう"
        content.body  = "monofulで色をチェックして、特別な一枚を残そう📸"
        content.sound = .default

        var comps = DateComponents()
        comps.hour = 10
        comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: LocalNotifyID.daily10, content: content, trigger: trigger)

        center.add(req) { error in
            if let error = error { print("scheduleDaily10AM error:", error) }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound, .badge])
    }
}

