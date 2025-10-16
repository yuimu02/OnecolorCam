//
//  ToastManager.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/10/15.
//

import Foundation
import SwiftUI

@MainActor
final class ToastManager: ObservableObject {
    @Published var message: String? = nil
    @Published var isShowing: Bool = false

    func show(_ message: String, duration: TimeInterval = 1.2) {
        self.message = message
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            self.isShowing = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            withAnimation(.easeOut(duration: 0.2)) {
                self.isShowing = false
            }
        }
    }
}

// MARK: - トーストUI
struct ToastViewModifier: ViewModifier {
    @ObservedObject var manager: ToastManager

    func body(content: Content) -> some View {
        ZStack {
            content
            if manager.isShowing, let message = manager.message {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 24)      
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 10)
                        .padding(.bottom, 60)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// MARK: - View拡張
extension View {
    func toast(manager: ToastManager) -> some View {
        self.modifier(ToastViewModifier(manager: manager))
    }
}
