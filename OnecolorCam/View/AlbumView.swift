//
//  AlbumView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/09/22.
//

import SwiftUI
import ColorfulX
import Kingfisher
struct AlbumView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HomeViewModel()
    let posts: [IMagepost]
    @State var index: Int
    @State private var pagerPayload: ImagePagerPayload?
    
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        f.dateFormat = "yyyy.MM.dd.E"
        return f
    }()
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            ScrollView {
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(posts.indices, id: \.self) { i in
                            Button {
                                pagerPayload = .init(posts: posts, startIndex: i)
                            } label: {
                                if let url = URL(string: posts[i].URLString) {
                                    KFImage(url)
                                        .placeholder {
                                            ProgressView()
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .background(Color.gray.opacity(0.15))
                                        }
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill) // 正方形トリミング
                                        .clipped()
                                } else {
                                    Color.gray.opacity(0.15)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(height: 110)
                            .clipped()
                            .cornerRadius(12)
                            .shadow(radius: 4)
                        }
                    }
                    .padding(.all, 12)
                }
            }
            .background(.clear)
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .sheet(item: $pagerPayload) { payload in
            ImageDetailPagerSheet(posts: payload.posts, index: payload.startIndex)
        }
    }
}
