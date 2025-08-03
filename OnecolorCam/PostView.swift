//
//  PostView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/21.
//

import SwiftUI
import ColorfulX

struct PostView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)
            
            
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Image("sample")
            }
        }
    }
   
}

#Preview {
    ContentView()
}
