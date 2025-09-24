// HomeView.swift

import SwiftUI
import ColorfulX
import AppleSignInFirebase
import FirebaseFirestore
import ColorExtensions
import CoreImage.CIFilterBuiltins

enum Tab {
    case home
    case others
    case camera
}

struct IMagepost: Codable {
    @DocumentID var id: String?
    var created:Date = Date()
    var URLString:String
    var publiccolor: String?
    var isPublic: Bool?
}

struct ImagePagerPayload: Identifiable {
    let id = UUID()
    let posts: [IMagepost]
    let startIndex: Int
}


struct HomeView: View {
    let year: Int
    let month: Int
    @Binding var tab: Tab
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(AuthManager.self) var authManager
    @State var images: [IMagepost] = []
    @State private var isShowingPager = false
    @State private var postsForSelectedDay: [IMagepost] = []
    @State private var startIndex: Int = 0
    @State private var pagerPayload: ImagePagerPayload?
    @State private var showAlbum = false
    @State private var isShowingQRSheet = false
    
    
    private var days: [Int?] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        
        let components = DateComponents(year: year, month: month, day: 1)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }
        
        let numDays = range.count
        let weekday = calendar.component(.weekday, from: firstDay)
        
        var result: [Int?] = Array(repeating: nil, count: weekday - 1)
        result.append(contentsOf: (1...numDays).map { Optional($0) })
        
        while result.count < 42 {
            result.append(nil)
        }
        
        return result
    }
    
    // MARK: - Helper Function to Find Image URL
    /// Searches the `images` array for a post matching the given day.
    private func findImagePost(for day: Int) -> [IMagepost] {
        let calendar = Calendar.current
        // Create a target date for the specific day in the current month and year
        guard let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            return []
        }
        
        return images
            .filter { calendar.isDate($0.created, inSameDayAs: targetDate) }
            .sorted { $0.created > $1.created }
    }
    
    private func findPostsOneMonthAgo() -> [IMagepost] {
        guard let targetDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
            return []
        }
        return images
            .filter { Calendar.current.isDate($0.created, inSameDayAs: targetDate) }
            .sorted { $0.created > $1.created }
    }
    
    private func isPosted(on date: Date) -> Bool {
        images.contains { Calendar.current.isDate($0.created, inSameDayAs: date) }
    }
    
    private func computeStreak(endingAt endDate: Date = Date()) -> Int {
        var streak = 0
        var day = endDate
        while isPosted(on: day) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                ColorfulView(color: $viewModel.colors)
                    .ignoresSafeArea()
                
                VStack {
                    
                    HStack(spacing: 12) {
                        Text(viewModel.formattedDate)
                            .font(.system(size: 21))
                            .foregroundColor(.black)
                        if let uid = AuthManager.shared.user?.uid {
                            Circle()
                                .fill(colorForToday(date: Date(), uid: uid))
                                .frame(width: 17, height: 17)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 14)
                    .padding()
                    
                    MonthPager(images: images) { posts in
                        pagerPayload = .init(posts: posts, startIndex: 0)
                    }
                    Spacer()
                    HStack {
                        let oneMonthAgoPosts = findPostsOneMonthAgo()
                        let currentStreak = computeStreak()
                        
                        if let post = oneMonthAgoPosts.first,
                           let url = URL(string: post.URLString) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("One Month Ago")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .frame(width: 140, height: 140)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                        .onTapGesture {
                                            pagerPayload = .init(posts: oneMonthAgoPosts, startIndex: 0)
                                        }
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            .padding(.top, 7)
                            .padding(.trailing, 35)
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "clock")
                                Text("1ヶ月前の今日は未投稿です")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
                            .padding(.vertical, 10)
                            .frame(width: 170, height: 140)
                            .padding(.trailing, 35)
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("You’re on a")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.leading, -13)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("\(currentStreak)")
                                    .font(.system(size: 40, weight: .bold))
                                    .monospacedDigit()
                                
                                Text("day run 🔥")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    HStack(spacing: 34) {
                        Button {
                        } label: {
                            Image(systemName: "house.fill")
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
                                        .stroke(Color.black, lineWidth: 1.7)
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
                            tab = .others
                        } label: {
                            Image(systemName: "person.3")
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
                                        .stroke(Color.black, lineWidth: 0.8)
                                )
                        }
                        .offset(y: -10)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .onAppear {
                viewModel.updateDate()
                Task {
                    Task { await loadAllImagesMixed()}
                }
            }
            .sheet(item: $pagerPayload) { payload in
                ImageDetailPagerSheet(posts: payload.posts, index: payload.startIndex)
            }
            .sheet(isPresented: $isShowingQRSheet) {
                VStack {
                    Text("MyQRコード")
                        .font(.headline)
                        .padding()
                    
                    if let uid = AuthManager.shared.user?.uid,
                       let uiimage = generateQR(url: "monoful-ios://user/\(uid)") {
                        Image(uiImage: uiimage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding()
                            .background(Color.white)
                    } else {
                        ProgressView()
                    }
                    Spacer()
                    
                    Text("カメラアプリでスキャンしてください")
                        .font(.headline)
                        .padding()
                }
                .presentationDetents([.medium, .large])
            }
            .refreshable {
                Task {
                    await loadAllImagesMixed()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingQRSheet = true
                    } label: {
                        Image(systemName: "qrcode")
                            .font(.system(size: 22, weight: .semibold))
                    }
                    .tint(.black)
                    .padding(.top, 8)
                    .padding(.leading, 8)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AlbumView(posts: images, index: 0)
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 22, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                    }
                    .tint(.black)
                    .disabled(images.isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @MainActor
    func loadAllImagesMixed() async {
        guard let uid = AuthManager.shared.user?.uid else { return }
        do {
            let uid = AuthManager.shared.user?.uid ?? ""
            let privateItems = try await FirebaseManager.getAllMyItems(uid: uid)
            
            // 取得したものを新しい順にソートして代入
            self.images = privateItems.sorted { $0.created > $1.created }
        } catch {
            print("loadAllImagesMixed error:", error)
        }
    }
    func generateQR(url: String) -> UIImage? {
        let data = url.data(using: .utf8)!
        let qr = CIFilter.qrCodeGenerator()
        qr.setDefaults()
        qr.message = data
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = qr.outputImage?.transformed(by: sizeTransform) else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

struct DateBadge: View {
    let day: Int
    var body: some View {
        Text("\(day)")
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundColor(.white)
    }
}

struct ImageDetailPagerSheet: View {
    @StateObject private var viewModel = HomeViewModel()
    let posts: [IMagepost]
    @State var index: Int   // 開始位置
    
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        f.dateFormat = "yyyy.MM.dd.E"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            
            TabView(selection: $index) {
                ForEach(posts.indices, id: \.self) { i in
                    VStack(spacing: 16) {
                        if let url = URL(string: posts[i].URLString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(22)
                                    .shadow(radius: 10)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Text("画像がありません")
                        }
                        
                        HStack(spacing: 12) {
                            Text(Self.df.string(from: posts[i].created))
                                .font(.title3).bold()
                                .padding(.top, 50)
                            
                            if let hex = posts[i].publiccolor {
                                Circle()
                                    .fill(hex.color)
                                    .frame(width: 17, height: 17)
                                    .padding(.top, 50)
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                    .tag(i)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        }
    }
}

struct GlassRect: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(.ultraThinMaterial)
            .aspectRatio(1, contentMode: .fit)
    }
}

//#Preview {
//    HomeView(year: 2025, month: 8)
//}
