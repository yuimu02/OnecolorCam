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

struct PostView: View {
    @Environment(AuthManager.self) var authManager
    @StateObject private var viewModel = HomeViewModel()
    let image: UIImage
    
    var body: some View {
        if authManager.isSignedIn {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                ColorfulView(color: $viewModel.colors)
                    .ignoresSafeArea()
                    .opacity(0.7)
                
                VStack {
                    Text("Hello, World!")
//                    Image("Sample")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)

                    Button("画像をアップロード") {
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
                }
            }
        } else {
            SignInWithAppleFirebaseButton()
        }
    }
//    func UploadImage() {
//        let storageref = Storage.storage().reference(forURL: "gs://onecolorcam.firebasestorage.app").child("Item")
//        
//        // オプショナルバインディングで安全に画像を読み込む
//        guard let image = UIImage(named: "Sample") else {
//            print("エラー：'Sample'という名前の画像が見つかりません。")
//            return
//        }
//        
//        // 画像のアルファチャンネル（透明度）を削除して、新しいUIImageを作成する
//        let newImage = removeAlpha(image)
//        
//        // jpegDataへの変換を再度試す
//        guard let data = newImage.jpegData(compressionQuality: 1.0) else {
//            print("エラー：jpegDataへの変換に失敗しました。")
//            return
//        }
//        
//        let nsData = data as NSData
//        
//        storageref.putData(data, metadata: nil) { (data, error) in
//            if let error = error {
//                print("エラー：画像のアップロードに失敗しました。\(error.localizedDescription)")
//                return
//            }
//            print("画像が正常にアップロードされました。")
//        }
//    }

    // UIImageのアルファチャンネルを削除するヘルパー関数
    func removeAlpha(_ image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale // 元の画像のスケールを維持
        format.opaque = true // 不透明に設定
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        
        let newImage = renderer.image { context in
            image.draw(at: .zero)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: image.size))
        }
        return newImage
    }
}

#Preview {
    ContentView()
}

struct IMagepost: Codable {
    @DocumentID var id: String?
    var created:Date = Date()
    var URLString:String
}
