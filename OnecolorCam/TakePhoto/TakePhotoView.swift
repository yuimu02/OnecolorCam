//
//  TakePhotoView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/30.
//

import SwiftUI
import ColorfulX


struct TakePhotoView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State var trigger = Trigger()
    @State private var currentTab: Tab = .camera
    @State private var capturedImage: UIImage? = nil
    @State private var isShowingPostView = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)
            
            VStack {
                Text(viewModel.formattedDate)
                    .font(.system(size: 20))
                    .padding()
                    .foregroundColor(.black)
                
                GeometryReader { geometry in
                                let side = min(geometry.size.width - 40, geometry.size.height)
                    SimpleCameraView(trigger: $trigger) { uiimage in
                        print("photo taken")
                        capturedImage = uiimage
                        isShowingPostView = true
                    }
                                .frame(width: side, height: side)
                                .clipped()
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                .padding(.top, 40) // 少し上に余白
                            }
                            .aspectRatio(1, contentMode: .fit)
                
                Button() {
                    trigger.fire()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.6), lineWidth: 4)
                        )
                        .shadow(radius: 3)
                }
                .padding(.top, 33)
                
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
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                    }
                    .disabled(currentTab == .camera)
                    
                    NavigationLink(destination: OthersPostsView()) {
                            Image(systemName: "person.3")
                                .font(.title2)
                                .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                    }
                }
                .padding(.bottom, 30)
                .navigationDestination(isPresented: $isShowingPostView) {
                    if let image = capturedImage {
                        PostView(image: image)
                    }
                }
        }
    }
}
}
