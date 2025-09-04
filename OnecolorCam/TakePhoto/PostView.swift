//
//  PostView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/21.
//

import SwiftUI
import ColorfulX
import AppleSignInFirebase
import Firebase
import FirebaseStorage
import FirebaseFirestore
import RenderableView

struct PostView: View {
    @Environment(AuthManager.self) var authManager
    @StateObject private var viewModel = HomeViewModel()
    @State var image: UIImage
    @State var updateCounter = 0
    
    
    
    init(image: UIImage) {
        self._image = .init(initialValue: image)
    }
    
    var body: some View {
        if authManager.isSignedIn {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                ColorfulView(color: $viewModel.colors)
                    .ignoresSafeArea()
                    .opacity(0.7)
                
                VStack {
                    Renderable(trigger: $updateCounter) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .cornerRadius(20)
                            .colorEffect(
                                Shader(
                                    function: ShaderFunction(
                                        library: .bundle(.main),
                                        name: "sample"
                                    ),
                                    arguments: [
                                        .float(getTodayHue()),
                                        .float(0.06),
                                    ]
                                )
                            )
                    } onTrigger: { data in
                        self.image = UIImage(data: data!)!
                        Task {
                            guard let uid = AuthManager.shared.user?.uid else { return }
                                    
                                    // 表示中の画像をそのまま加工（アルファを削除）
//                                    let newImage = removeAlpha(image)
                                    
                                    do {
                                        // Firebaseにアップロード
                                        let imageURL = try await FirebaseManager.sendImage(image: image, folderName: "folder")
                                        print("アップロード成功:", imageURL)
                                        let newPost = IMagepost(URLString: imageURL.absoluteString)
                                        try await FirebaseManager.addItem(item: newPost, uid: uid)
                                    } catch {
                                        print("アップロード失敗:", error)
                                    }
                        }
                    }
                    
                    HStack(spacing: 100) {
                        Button {
                            updateCounter += 1
                        } label: {
                            Image(systemName: "arrow.down.to.line.compact")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 0.8)
                                )
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "paperplane")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 0.8)
                                )
                        }
                    }
                    .padding(.top, 40)
                }
            }
        } else {
            SignInWithAppleFirebaseButton()
        }
    }
    func getTodayHue() -> Float {
            guard let uid = AuthManager.shared.user?.uid else { return 0.0 }
            let todaysColor = colorForToday(date: Date(), uid: uid)
            let hsv = todaysColor.toHSV()
            return hsv.h
        }
    func removeAlpha(_ image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { context in
            image.draw(at: .zero)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: image.size))
        }
    }
    // UIImageのアルファチャンネルを削除するヘルパー関数

}

extension Color {
    func toHSV() -> (h: Float, s: Float, v: Float) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        let maxc = max(r, g, b)
        let minc = min(r, g, b)
        let delta = maxc - minc
        
        var h: Float = 0
        if delta > 0.00001 {
            if maxc == r { h = fmodf(Float((g - b)/delta), 6) }
            else if maxc == g { h = Float((b - r)/delta) + 2 }
            else { h = Float((r - g)/delta) + 4 }
            h /= 6
            if h < 0 { h += 1 }
        }
        let s: Float = maxc == 0 ? 0 : Float(delta / maxc)
        let v: Float = Float(maxc)
        return (h, s, v)
    }
}


#Preview {
    ContentView()
}
