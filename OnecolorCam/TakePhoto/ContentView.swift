//
//  ContentView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/04/29.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTab: Tab = .home
    var body: some View {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        
        HomeView(year: year, month: month, tab: $currentTab)
    }
}


#Preview {
    ContentView()
}
