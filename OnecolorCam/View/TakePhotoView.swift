//
//  TakePhotoView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/30.
//

import SwiftUI
import ColorfulX
import AppleSignInFirebase

class FriendTempColor {
    static var friendColor: Color?
}

    extension UIImage {
        func croppedToSquare() -> UIImage {
            let src = self.fixedOrientation()
            let w = src.size.width, h = src.size.height
            let side = min(w, h)
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
    @State private var isShowingQR = false
    
    var body: some View {
        NavigationStack {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)
            let todayColor: Color = {
                if let uid = AuthManager.shared.user?.uid {
                    return colorForToday(date: Date(), uid: uid)
                } else {
                    return .black
                }
            }()
            VStack {
                HStack(spacing: 12) {
                    Text(viewModel.formattedDate)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                    if let uid = AuthManager.shared.user?.uid {
                        Circle()
                            .fill(colorForToday(date: Date(), uid: uid))
                            .frame(width: 17, height: 17)
                    }
                }
                .padding(.top, 60)
                .padding()
                
                GeometryReader { geometry in
                    let width = max(1, geometry.size.width - 40)

                    SimpleCameraView(trigger: $trigger) { uiimage in
                        capturedImage = uiimage.croppedToSquare()
                        isShowingPostView = true
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: width)
                    .cornerRadius(12)
                    .compositingGroup()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 14)
                .padding(.top, 20)

                    if let uid = AuthManager.shared.user?.uid {
                        let hex = colorForToday(date: Date(), uid: uid).hex
                        Spacer()
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
                        .padding(.top, 18)
                        .padding(.bottom, 33)
                        
                }

                Spacer()
                
                HStack(spacing: 34) {
                    Button {
                        tab = .home
                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 24))
                            .foregroundColor(Color(white: 0.26))
                            .frame(width: 68, height: 68)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(white: 0.26), lineWidth: 0.8)
                            )
                    }
                    .offset(y: -10)
                    
                    Button {
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(white: 0.26))
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(white: 0.26), lineWidth: 1.7)
                            )
                    }
                    .offset(y: 10)
                    
                    Button {
                        tab = .others
                    } label: {
                        Image(systemName: "person.3")
                            .font(.system(size: 23))
                            .foregroundColor(Color(white: 0.26))
                            .frame(width: 68, height: 68)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(white: 0.26), lineWidth: 0.8)
                            )
                    }
                    .offset(y: -10)
                }
                .padding(.bottom, 10)
                
                
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
        .overlay(alignment: .bottomTrailing) {
            let todayColor: Color = {
                if let uid = AuthManager.shared.user?.uid {
                    return colorForToday(date: Date(), uid: uid)
                } else {
                    return .black
                }
            }()
            Button {
                isShowingQR = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
//                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
//                    .shadow(radius: 3)
                    .shadow(color: todayColor.opacity(1), radius: 1, x: 0, y: 0)
                    .shadow(color: todayColor.opacity(1), radius: 2, x: 0, y: 0)
                    .shadow(color: todayColor.opacity(1), radius: 2, x: 0, y: 0)
            }
            .padding(.trailing, 36)
            .padding(.bottom, 182) // 撮影ボタンより少し上に見えるよう微調整
        }
        .sheet(isPresented: $isShowingQR) {
            VStack(spacing: 12) {
                Text("友達と色を共有しよう！")
                    .font(.headline)

                if let uid = AuthManager.shared.user?.uid {
                    let hex = colorForToday(date: Date(), uid: uid)
                        .hex.replacingOccurrences(of: "#", with: "")
                    if let uiimage = viewModel.generateQR(url: "monoful-ios://color/\(hex)") {
                        Image(uiImage: uiimage)
                            .resizable().interpolation(.none).scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 3)
                    } else {
                        ProgressView()
                            .frame(height: 200)
                    }
                } else {
                    Text("サインインが必要です").foregroundColor(.secondary)
                }
                Text("カメラアプリで読み取ってもらおう！")
                    .font(.headline)

            }
            .padding()
            .presentationDetents([.height(370)])          // 伸びない固定サイズ
            .presentationDragIndicator(.hidden)           // つまみ非表示（任意）
            .presentationBackground(.ultraThinMaterial)
        }

    }
}
}

//if let uid = AuthManager.shared.user?.uid,
//   let uiimage = viewModel.generateQR(url: "monoful-ios://color/\(hex)") {
//    Image(uiImage: uiimage)
//        .resizable()
//        .interpolation(.none)
//        .scaledToFit()
//        .frame(width: 50, height: 50)
//        .padding()
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .shadow(radius: 3)
//} else {
//    ProgressView()
//}
