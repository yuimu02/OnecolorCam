//
//  OnecolorCamApp.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/04/29.
//

import SwiftUI
import AVFoundation
import FirebaseCore
import AppleSignInFirebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct OnecolorCamApp: App {
    init() {
        NotificationService.shared.configure()
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var toastManager = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environment(AuthManager.shared)
                .environmentObject(toastManager)     // ← 共有
                .toast(manager: toastManager)        // ← いつでも表示できる
                .onOpenURL { url in
                    guard let uid = AuthManager.shared.user?.uid else { return }
                    let userId = url.lastPathComponent

                    Task {
                        do {
                            try await FirebaseManager.addFriend(uid: uid, friendUid: userId)
                            await MainActor.run {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                toastManager.show("友達追加完了")
                            }
                        } catch {
                            await MainActor.run {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                toastManager.show("追加に失敗しました")
                            }
                        }
                    }
                }
            
        }
    }
}
