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
        NotificationService.shared.configure()   // ← 追加：起動時に許可＆毎朝10時を登録
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthView()
//            TestCameraView()
//            PostView()
//            TakePhotoView()
                .environment(AuthManager.shared)
        }
    }
}
