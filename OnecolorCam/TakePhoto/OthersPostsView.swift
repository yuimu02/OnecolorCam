//
//  OthersPostsView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/08/31.
//

import SwiftUI
import ColorfulX

struct OthersPostsView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var currentTab: Tab = .others
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            HStack(spacing: 34) {
                NavigationLink(destination: HomeView(year: 2025, month: 8)) {
                    Image(systemName: "house")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.3)) // 背景も丸く
                                .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 0.8) // 黒い縁
                        )
                }
                .offset(y: -10)
                
                NavigationLink(destination: TakePhotoView()) {
                    Image(systemName: "camera")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.3)) // 背景も丸く
                                .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 0.8) // 黒い縁
                        )
                }
                .offset(y: 10)
                
                NavigationLink(destination: OthersPostsView()) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.3)) // 背景も丸く
                                .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 1.7) // 黒い縁
                        )
                }
                .offset(y: -10)
                .disabled(currentTab == .others)
            }
            .padding(.bottom, 30)
        }
    }
}
}

#Preview {
    OthersPostsView()
}
