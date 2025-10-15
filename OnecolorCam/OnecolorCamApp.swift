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

                    // ★ 追加：host で分岐
                    let host = url.host?.lowercased() ?? ""

                    // ★ 追加：color 用の早期処理
                    if host == "color" {
                        let hex = url.lastPathComponent
                        let normalized = hex.hasPrefix("#") ? hex : "#\(hex)"

                        // ColorExtensions に Color(hex:) がある前提
                        if let color = Color(hex: normalized) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            toastManager.show("カラーを読み込みました: \(normalized)")
                            // ここで必要なら表示/状態更新を行う（例）
                            // self.viewModel.friendColor = color
                            // self.isShowingFriendColorSheet = true
                            
                            FriendTempColor.friendColor = color
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            toastManager.show("色コードが不正です: \(normalized)")
                        }
                        return
                    } else if host == "user" {
                        
                        // ▼ 既存の「友達追加」(monoful-ios://user/{uid}) はそのまま
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
}
