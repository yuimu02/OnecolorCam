//
//  OthersPostsView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/08/31.
//

import SwiftUI
import ColorfulX
import ColorExtensions
import AppleSignInFirebase

struct OthersPostsView: View {
    @StateObject private var viewModel = HomeViewModel()

    // 本番は IMagepost をそのまま使う
    @State private var posts: [IMagepost] = []
    @State private var index: Int = 0

    @Binding var tab: Tab

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)

            VStack {
                if posts.isEmpty {
                    Text("No public posts yet")
                        .font(.headline)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        TabView(selection: $index) {
                            ForEach(posts.indices, id: \.self) { i in
                                VStack(spacing: 16) {
                                    if let url = URL(string: posts[i].URLString) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, minHeight: 200)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: .infinity)
                                                    .cornerRadius(21)
                                                    .shadow(radius: 10)
                                            case .failure:
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(.ultraThinMaterial)
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 40, weight: .light))
                                                        .foregroundColor(.secondary)
                                                }
                                                .frame(maxWidth: .infinity, minHeight: 200)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(.ultraThinMaterial)
                                            Text("Invalid URL")
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 200)
                                    }
                                }
                                .padding(.horizontal)
                                .tag(i)
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                        .onChange(of: index) { newValue in
                            applyBackground(for: newValue)
                        }
                    }

                    // Bottom nav
                    HStack(spacing: 34) {
                        Button { tab = .home } label: {
                            Image(systemName: "house")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(Circle().stroke(Color.black, lineWidth: 0.8))
                        }
                        .offset(y: -10)

                        Button { tab = .camera } label: {
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(Circle().stroke(Color.black, lineWidth: 0.8))
                        }
                        .offset(y: 10)

                        Button {} label: {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(Circle().stroke(Color.black, lineWidth: 1.7))
                        }
                        .offset(y: -10)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .onAppear {
            posts = []
            index = 0
            applyBackground(for: 0) // 初期反映
            Task { await loadPublic() }
        }
        .refreshable {
            await loadPublic()
        }
    }

    // MARK: - Data Load
    @MainActor
    private func loadPublic() async {
        do {
            let uid = AuthManager.shared.user?.uid ?? "" // 署名に合わせて一応渡す
            let items = try await FirebaseManager.getAllPublicItems(uid: uid)

            // created の新しい順（Firestoreで orderBy 済みなら不要）
            let sorted = items.sorted { $0.created > $1.created }

            self.posts = sorted
            self.index = 0
            applyBackground(for: 0)
        } catch {
            print("public load error:", error.localizedDescription)
        }
    }

    // MARK: - Background
    private func applyBackground(for idx: Int) {
        guard posts.indices.contains(idx) else { return }
        // publiccolor（Hex）→ ColorExtensions で Color 化
        let base: Color = (posts[idx].publiccolor?.color) ?? .gray
        viewModel.colors = makePalette(from: base)
    }

    private func makePalette(from base: Color) -> [Color] {
        [
            base,
            base.opacity(0.85),
            base.opacity(0.7),
            base.opacity(0.55),
            base.opacity(0.4)
        ]
    }
}

