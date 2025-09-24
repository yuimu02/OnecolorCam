//
//  RootView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/09/05.
//

import SwiftUI

struct RootView : View {
    @State private var currentTab: Tab = .home
    let year = Calendar.current.component(.year, from: Date())
    let month = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        TabView(selection: $currentTab) {
            HomeView(year: year, month: month, tab: $currentTab)
                .tag(Tab.home)
            
            TakePhotoView(tab: $currentTab)
                .tag(Tab.camera)
            
            OthersPostsView(tab: $currentTab)
                .tag(Tab.others)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    RootView()
}
