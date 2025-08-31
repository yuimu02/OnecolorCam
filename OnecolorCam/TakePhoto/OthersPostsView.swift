//
//  OthersPostsView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/08/31.
//

import SwiftUI

struct OthersPostsView: View {
    
    @State private var currentTab: Tab = .others
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            HStack(spacing: 20) {
                NavigationLink(destination: HomeView(year: 2025, month: 8)) {
                    Image(systemName: "house")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial) // 半透明効果
                        .clipShape(Circle())
                }
                
                NavigationLink(destination: TakePhotoView()) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .disabled(currentTab == .camera)
                
                NavigationLink(destination: OthersPostsView()) {
                    Image(systemName: "person.3.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .disabled(currentTab == .others)
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    OthersPostsView()
}
