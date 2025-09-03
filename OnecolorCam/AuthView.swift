//
//  AuthView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/09/03.
//

import SwiftUI
import AppleSignInFirebase

struct AuthView: View {
    @Environment(AuthManager.self) var authManager
    var body: some View {
        if authManager.isSignedIn {
            ContentView()
        } else {
            SignInWithAppleFirebaseButton()
        }
    }
}

#Preview {
    AuthView()
}
