//
//  HomeView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/23.
//

// HomeView.swift

import SwiftUI
//import SimpleCamera
import ColorfulX
import AppleSignInFirebase
import FirebaseFirestore

enum Tab {
    case home
    case others
    case camera
}

struct ImagePost: Identifiable {
    var id: String
    var image: UIImage
    var created: Date
}

struct HomeView: View {
    let year: Int
    let month: Int
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(AuthManager.self) var authManager
    @State private var currentTab: Tab = .home
    @State var images: [ImagePost] = []
    
    private var days: [Int?] {
            var calendar = Calendar(identifier: .gregorian)
            calendar.firstWeekday = 1 // 日曜始まり

            // 指定年月の初日
            let components = DateComponents(year: year, month: month, day: 1)
            guard let firstDay = calendar.date(from: components),
                  let range = calendar.range(of: .day, in: .month, for: firstDay) else {
                return []
            }

            let numDays = range.count

            // 初日の曜日 (1=日曜, 2=月曜, … 7=土曜)
            let weekday = calendar.component(.weekday, from: firstDay)

            // 前の空欄 (weekday-1 個)
            var result: [Int?] = Array(repeating: nil, count: weekday - 1)

            // 1日から最終日まで
            result.append(contentsOf: (1...numDays).map { Optional($0) })

            // 42マスに合わせる（7列×6行）
            while result.count < 42 {
                result.append(nil)
            }

            return result
        }
    
    var body: some View {
        
//        if authManager.isSignedIn {
            
//            .buttonStyle(.borderedProminent)
            
            
            NavigationStack {
                ZStack {
                    Color.white
                    ColorfulView(color: $viewModel.colors)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("取得した画像数: \(images.count)")
                               .foregroundColor(.red)
                               .padding()
                        Text(viewModel.formattedDate)
                            .font(.system(size: 20))
                            .padding()
                            .foregroundColor(.black)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                            ForEach(days.indices, id: \.self) { index in
                                ZStack {
                                    GlassRect()
                                    
                                    if let day = days[index] {
                                        if year == 2025 && month == 8 && day == 21 {
                                            // 指定された日付なら画像を表示
                                            Image("Sample")
                                                .resizable()
                                                .scaledToFit()
                                                .padding(4)
                                        } else {
                                            // それ以外は日付を表示
                                            Text("\(day)")
                                                .foregroundColor(.black)
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                    }
                                }
                                .frame(height: 55) // マスの大きさ
                            }
                        }
                        Spacer()
                        
                        // 半透明の白っぽい背景にしたボタンを横に並べる
                        HStack(spacing: 20) {
                            NavigationLink(destination: HomeView(year: 2025, month: 8)) {
                                    Image(systemName: "house.fill")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(.ultraThinMaterial) // 半透明効果
                                .clipShape(Circle())
                            }
                            .disabled(currentTab == .home)
                            
                            NavigationLink(destination: TakePhotoView()) {
                                    Image(systemName: "camera")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                            }
                            
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
                               }
                        
//                        HStack {
//                            Button("赤") {
//                                viewModel.selectColor(hue: 0.99, range: 0.1)
//                            }
//                            Button("緑") {
//                                viewModel.selectColor(hue: 0.33, range: 0.13)
//                            }
//                            Button("青") {
//                                viewModel.selectColor(hue: 0.66, range: 0.08)
//                            }
//                            Button("元に戻す") {
//                                viewModel.resetColorRange()
//                            }
//                        }
                        .padding()
                        
                        //                    Image("Sample")
                        //                        .resizable()
                        //                        .aspectRatio(contentMode: .fit)
                        //                        .colorEffect(
                        //                            Shader(
                        //                                function: ShaderFunction(
                        //                                    library: .bundle(.main),
                        //                                    name: "sample"
                        //                                ),
                        //                                arguments: [
                        //                                    .float(viewModel.hueToDisplay),
                        //                                    .float(viewModel.range),
                        //                                    .color(viewModel.color)
                        //                                ]
                        //                            )
                        //                        )
                        
//                        Button("trst") {
//                            viewModel.showNextView = true
//                        }
                    }
                    .onAppear {
                        viewModel.updateDate()
                        Task {
                            try! await loadAllImages()
                        }
                    }
                    .sheet(
                        isPresented: Binding(
                            get: { viewModel.takenPhoto != nil },
                            set: { _ in viewModel.takenPhoto = nil }
                        )
                    ) {
                        if let image = viewModel.takenPhoto {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .refreshable {
                        Task {
                            try! await loadAllImages()
                        }
                    }
                }
            }
    func loadAllImages() async throws {
        guard let uid = AuthManager.shared.user?.uid else { return }
        let db = Firestore.firestore()
        
        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("posts")
            .order(by: "created", descending: true)
            .getDocuments()
        
        for document in snapshot.documents {
            guard let urlString = document["URLString"] as? String,
                  let url = URL(string: urlString),
                  let timestamp = document["created"] as? Timestamp else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    images.append(
                        ImagePost(id: document.documentID, image: uiImage, created: timestamp.dateValue())
                    )
                }
            } catch {
                print("画像の取得に失敗:", error)
            }
        }
        
        await MainActor.run {
            self.images = images
        }
    }

    }
//        } else {
//            SignInWithAppleFirebaseButton()
//        }


struct GlassRect: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(.ultraThinMaterial)
            .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    HomeView(year: 2025, month: 8)
}

