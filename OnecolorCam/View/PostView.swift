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
import ColorExtensions

struct PostView: View {
    @Environment(AuthManager.self) var authManager
    @StateObject private var viewModel = HomeViewModel()
    @Binding var tab: Tab
    @State private var image: UIImage
    @State private var updateCounter = 0
    @Environment(\.dismiss) private var dismiss
    @State private var willPostPublic = false

    // ▼ 追加：保存後のポップアップ表示・状態
    @State private var showShareDialog = false
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var lastSavedPost: IMagepost? = nil
    @State private var lastSavedUIImage: UIImage? = nil

    init(image: UIImage, tab: Binding<Tab>) {
        self._image = State(initialValue: image)
        self._tab = tab
    }

    var body: some View {
        if authManager.isSignedIn {
            ZStack {
                Color.white.ignoresSafeArea()
                ColorfulView(color: $viewModel.colors)
                    .ignoresSafeArea()
                    .opacity(0.7)

                VStack {
                    HStack(spacing: 12) {
                        Text(viewModel.formattedDate)
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.black)
                        if let uid = AuthManager.shared.user?.uid {
                            Circle()
                                .fill(colorForToday(date: Date(), uid: uid))
                                .frame(width: 19, height: 19)
                        }
                    }
                    .padding()

                    Renderable(trigger: $updateCounter) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                alignment: .topTrailing
                            ) {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(6)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(.plain)
                                .padding(10)
                            }
                            .colorEffect(
                                Shader(
                                    function: ShaderFunction(
                                        library: .bundle(.main),
                                        name: "sample"
                                    ),
                                    arguments: [
                                        .float(getTodayHue()),
                                        .float(0.1),
                                    ]
                                )
                            )
                    } onTrigger: { data in
                        // レンダ済み画像に差し替え
                        if let d = data, let rendered = UIImage(data: d) {
                            self.image = rendered
                        }

                        // ▼ 保存処理
                        Task { @MainActor in
                            guard let uid = AuthManager.shared.user?.uid else { return }
                            isSaving = true
                            saveError = nil
                            do {
                                let imageURL = try await FirebaseManager.sendImage(image: image, folderName: "folder")
                                let hex = colorForToday(date: Date(), uid: uid).hex
                                let newPost = IMagepost(
                                    URLString: imageURL.absoluteString,
                                    publiccolor: hex,
                                    isPublic: willPostPublic
                                )
                                try FirebaseManager.addItem(item: newPost, uid: uid)

                                self.lastSavedPost = newPost
                                self.lastSavedUIImage = image        // ← ここで実際のUIImageを握る
                                self.showShareDialog = true
                            } catch {
                                self.saveError = "保存に失敗: \(error.localizedDescription)"
                            }
                            isSaving = false
                        }
                    }

                    HStack(spacing: 100) {
                        // 端末保存のみ
                        Button {
                            willPostPublic = false
                            updateCounter += 1
                            // ここでは遷移しない。保存→ポップアップで処理する
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
                                    Circle().stroke(Color.black, lineWidth: 0.8)
                                )
                        }

                        // 公開ポスト
                        Button {
                            willPostPublic = true
                            updateCounter += 1
                            // ここでも遷移しない。保存→ポップアップで処理する
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
                                    Circle().stroke(Color.black, lineWidth: 0.8)
                                )
                        }
                    }
                    .padding(.top, 40)

                    if isSaving {
                        ProgressView("保存中…")
                            .padding(.top, 12)
                    }
                    if let err = saveError {
                        Text(err).foregroundColor(.red).font(.footnote).padding(.top, 6)
                    }
                }
            }
            // ▼ 保存後のポップアップ：ストーリーズへ飛ばす
            .confirmationDialog("保存完了。どうする？",
                                isPresented: $showShareDialog,
                                titleVisibility: .visible) {
                Button("Instagramストーリーズへ") {
                    Task { await shareToInstagram() }
                }
                Button("閉じる", role: .cancel) {
                    // キャンセル時にホームへ戻す
                    dismiss()
                    tab = .home
                }
            }
        } else {
            SignInWithAppleFirebaseButton()
        }
    }

    private func shareToInstagram() async {
        guard let post = lastSavedPost,
              let baseImage = lastSavedUIImage else {
            await actuallyShare(stickerImage: image)
            return
        }

        let sticker = renderStorySticker(
            image: baseImage,
            publicColorHex: post.publiccolor ?? "#000000",
            urlString: post.URLString,
            created: post.created
        )
        await actuallyShare(stickerImage: sticker)
    }
    func renderStorySticker(image: UIImage,
                            publicColorHex: String,
                            urlString: String,
                            created: Date,
                            scale: CGFloat = 3) -> UIImage {
        let view = StoryStickerView(
            image: image,
            publicColorHex: publicColorHex,
            urlString: urlString,
            created: created
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        renderer.isOpaque = true
        return renderer.uiImage ?? image
    }

    @MainActor
    private func actuallyShare(stickerImage: UIImage) async {
        guard let url = URL(string: "https://x.com") else { return }
        do {
            let outcome = try await InstagramRepository.shared.share(
                stickerImage: stickerImage,
                backgroundTopColor: "#FFFFFF",
                backgroundBottomColor: "#FFFFFF",
                contentURL: url
            )
            // 必要なら分岐してトーストなど表示
            switch outcome {
            case .openedStories:
                print("IG Stories に直接遷移")
            case .openedInstagramApp:
                print("Instagramアプリを起動（Stories直行不可ケース）")
            case .openedAppStore:
                print("Instagram未インストール → App Storeへ誘導")
            }
        } catch {
            print("share error: \(error)")
            // ここで自前アラートなど
        }
    }
    
    func getTodayHue() -> Float {
        guard let uid = AuthManager.shared.user?.uid else { return 0.0 }
        let todaysColor = colorForToday(date: Date(), uid: uid)
        let hsv = todaysColor.toHSV()
        return hsv.h
    }

    // 透明を白で埋める（StoriesのPNGで安全）
    func removeAlpha(_ image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: image.size))
            image.draw(at: .zero)
        }
    }
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
