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
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environment(AuthManager.shared)
                .onOpenURL { url in
                    if let uid = AuthManager.shared.user?.uid {
                        let userId = url.lastPathComponent

                        Task {
                            try await FirebaseManager.addFriend(uid: uid, friendUid: userId)
                        }
                    }
                }
            
        }
    }
}
