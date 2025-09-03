//
//  TakePhotoView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/30.
//

import SwiftUI
import ColorfulX

    extension UIImage {
        func croppedToSquare() -> UIImage {
            let src = self.fixedOrientation()
            let w = src.size.width, h = src.size.height
            let side = min(w, h)
//            let x = (w - side) / 2.0
//            let y = (h - side) / 2.0
            let x: CGFloat = 0
            let y: CGFloat = 0

            let format = UIGraphicsImageRendererFormat.default()
            format.scale = src.scale   // 解像度維持
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)

            return renderer.image { _ in
                src.draw(in: CGRect(x: -x, y: -y, width: w, height: h))
            }
        }
        func fixedOrientation() -> UIImage {
            if imageOrientation == .up { return self }
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img ?? self
        }
    }

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
                        capturedImage = uiimage.croppedToSquare()
                        isShowingPostView = true
                    }
                    .frame(width: side, height: side)
                    .scaledToFill()
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
                            Image(systemName: "camera.fill")
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
                                .stroke(Color.black, lineWidth: 1.7) // 黒い縁
                        )
                    }
                    .offset(y: 10)
                    .disabled(currentTab == .camera)
                    
                    NavigationLink(destination: OthersPostsView()) {
                            Image(systemName: "person.3")
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
                                .stroke(Color.black, lineWidth: 0.8) // 黒い縁
                        )
                    }
                    .offset(y: -10)
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
