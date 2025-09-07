//
//  TakePhotoView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/30.
//

import SwiftUI
import ColorfulX
import AppleSignInFirebase

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
    @State private var capturedImage: UIImage? = nil
    @State private var isShowingPostView = false
    @Binding var tab: Tab
    
    var body: some View {
        NavigationStack {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)
            
            VStack {
                HStack(spacing: 12) {
                    Text(viewModel.formattedDate)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                    if let uid = AuthManager.shared.user?.uid {
                        Circle()
                            .fill(colorForToday(date: Date(), uid: uid)) // 今日の色
                            .frame(width: 17, height: 17)                 // 丸の大きさ
                        //                                .overlay(
                        //                                    Circle().stroke(Color.black.opacity(0.1), lineWidth: 1)
                        //                                )
                    }
                }
                .padding(.top, 45)
                .padding(.bottom, 14)
                .padding()
                
                GeometryReader { geometry in
                    let width = max(1, geometry.size.width - 40)

                    SimpleCameraView(trigger: $trigger) { uiimage in
                        capturedImage = uiimage.croppedToSquare()
                        isShowingPostView = true
                    }
                    .aspectRatio(1, contentMode: .fit) // 正方形をここで担保
                    .frame(width: width)// 高さは比率から決まるので指定しない
                    .cornerRadius(12)
                    .compositingGroup()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 14)
                .padding(.top, 40)

                
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
                    Button {
                        tab = .home
                    } label: {
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
                    
                    Button {
                    } label: {
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
                    
                    Button {
                        tab = .others
                    } label: {
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
            }
        }
        .navigationDestination(isPresented: $isShowingPostView) {
            if let img = capturedImage {
                PostView(image: img, tab: $tab)
                    .navigationBarBackButtonHidden(true)
            } else {
                EmptyView()
            }
        }
//        .onChange(of: isShowingPostView) { newValue in
//            if !newValue {
//                capturedImage = nil       // 戻ってきたときだけリセット
//            }
//        }
    }
}
}
