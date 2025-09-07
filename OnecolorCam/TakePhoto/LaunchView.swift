//
//  LaunchView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/09/06.
//

import SwiftUI

struct LaunchView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        Image("launchback")
            .resizable()
            .scaledToFill()    // 画面いっぱいに表示（必要に応じて一部トリミング）
            .ignoresSafeArea() // ノッチやホームインジケータも含めて全面
            .accessibilityHidden(true)

    }
}
