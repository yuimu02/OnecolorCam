//
//  OthersPostsView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/08/31.
//

import SwiftUI
import ColorfulX

struct SamplePublicPhoto: Identifiable {
    let id = UUID()
    let imageName: String
    let color: Color
}

struct OthersPostsView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var posts: [SamplePublicPhoto] = []
    @State private var index: Int = 0
    @Binding var tab: Tab

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ColorfulView(color: $viewModel.colors)
                .ignoresSafeArea()
                .opacity(0.7)

            VStack {
                // 見出しなど必要なら
                // Text("Everyone's Photos").font(.headline)

                if posts.isEmpty {
                    Text("No samples")
                        .font(.headline)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        TabView(selection: $index) {
                            ForEach(posts.indices, id: \.self) { i in
                                VStack(spacing: 16) {
                                    Image(posts[i].imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(14)
                                        .shadow(radius: 10)
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

                    // ボトムナビ
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
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 0.8)
                                )
                        }
                        .offset(y: -10)

                        Button {
                            tab = .camera
                        } label: {
                            Image(systemName: "camera")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 80)
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
                        .offset(y: 10)

                        Button {
                        } label: {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1.7)
                                )
                        }
                        .offset(y: -10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .padding() // 全体の余白（ScrollView を置くなら無視したいところだけ個別に調整）
        }
        // ここに付けるのが大事（VStack 内だと発火しない場合がある）
        .onAppear {
            // 左端＝最新 → 右へ行くほど古い
            posts = [
                SamplePublicPhoto(imageName: "Sample", color: .red),
                SamplePublicPhoto(imageName: "Sample2", color: .blue),
                SamplePublicPhoto(imageName: "Sample3", color: .pink),
                SamplePublicPhoto(imageName: "Sample4", color: .green),
                SamplePublicPhoto(imageName: "Sample5", color: .brown)
            ]
            index = 0
            applyBackground(for: 0) // 初期表示でも背景反映
        }
    }


    private func applyBackground(for idx: Int) {
        guard posts.indices.contains(idx) else { return }
        let base = posts[idx].color
        viewModel.colors = makePalette(from: base)
    }

    private func makePalette(from base: Color) -> [Color] {
        // 必要なら getNearColors(...) に置き換えてOK
        [
            base,
            base.opacity(0.85),
            base.opacity(0.7),
            base.opacity(0.55),
            base.opacity(0.4)
        ]
    }
}

//#Preview {
//    OthersPostsView()
//}
