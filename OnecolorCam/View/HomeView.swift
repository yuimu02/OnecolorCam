// HomeView.swift

import SwiftUI
import ColorfulX
import AppleSignInFirebase
import FirebaseFirestore
import ColorExtensions
import CoreImage.CIFilterBuiltins
import UIKit
import Kingfisher

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

struct HueBucket: Identifiable {
    let id = UUID()
    let index: Int            // 0..(bins-1)
    let degreeCenter: Double  // 中心角（UI用）
    let posts: [IMagepost]
}


private extension String {
    var toUIColor: UIColor? {
        var hex = trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let v = Int(hex, radix: 16) else { return nil }
        let r = CGFloat((v >> 16) & 0xFF) / 255
        let g = CGFloat((v >> 8) & 0xFF) / 255
        let b = CGFloat(v & 0xFF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
private func hueDegree(from hex: String) -> Double? {
    guard let ui = hex.toUIColor else { return nil }
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return Double(h * 360.0)
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
    
    func buildHueBuckets(posts: [IMagepost], year: Int, month: Int, bins: Int = 36) -> [HueBucket] {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        let comps = DateComponents(year: year, month: month, day: 1)
        guard let start = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: start),
              let end = cal.date(byAdding: .day, value: range.count, to: start) else {
            return (0..<bins).map { HueBucket(index: $0, degreeCenter: (Double($0)+0.5)*(360.0/Double(bins)), posts: []) }
        }

        var buckets: [[IMagepost]] = Array(repeating: [], count: bins)
        let width = 360.0 / Double(bins)

        for p in posts {
            guard (start..<end).contains(p.created),
                  let hex = p.publiccolor,
                  let deg = hueDegree(from: hex) else { continue }
            let idx = min(Int(deg / width), bins - 1)
            buckets[idx].append(p)
        }

        return (0..<bins).map { i in
            HueBucket(index: i,
                      degreeCenter: (Double(i) + 0.5) * width,
                      posts: buckets[i].sorted { $0.created > $1.created })
        }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                ColorfulView(color: $viewModel.colors)
                    .ignoresSafeArea()
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
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                        if let uid = AuthManager.shared.user?.uid {
                            Circle()
                                .fill(colorForToday(date: Date(), uid: uid))
                                .frame(width: 17, height: 17)
                        }
                    }
                    .padding(.top, 30)
                    .padding()
                    
                    MonthPager(images: images) { posts in
                        pagerPayload = .init(posts: posts, startIndex: 0)
                    }
                    Spacer()
                    HStack {
                        let oneMonthAgoPosts = findPostsOneMonthAgo()
                        let currentStreak = computeStreak()
                        let hueBuckets = buildHueBuckets(posts: images, year: year, month: month, bins: 36)
                        
                        if let post = oneMonthAgoPosts.first,
                           let url = URL(string: post.URLString) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("One Month Ago")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                                KFImage(url)
                                    .placeholder {
                                        ProgressView()
                                            .frame(width: 140, height: 140)
                                    }
                                    .fade(duration: 0.25) // フェードイン演出（任意）
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 140, height: 140)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                    .onTapGesture {
                                        pagerPayload = .init(posts: oneMonthAgoPosts, startIndex: 0)
                                    }
                            }
                            .padding(.top, 7)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "clock")
                                Text("1ヶ月前の今日は未投稿です")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
                            .padding(.vertical, 10)
                            .frame(width: 170, height: 140)
                            .padding(.trailing, 35)
                        }
                        
                        
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("You’re on a")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                                .padding(.leading, -13)
//                            
//                            HStack(alignment: .firstTextBaseline, spacing: 6) {
//                                Text("\(currentStreak)")
//                                    .font(.system(size: 40, weight: .bold))
//                                    .monospacedDigit()
//                                
//                                Text("day run 🔥")
//                                    .font(.headline)
//                                    .foregroundColor(.primary)
//                            }
//                        }
                        VStack{
                            StreakChip(count: currentStreak)
                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.top, 4)

                            HueRingInteractive(buckets: hueBuckets, diameter: 130, ringWidth: 22) { selectedPosts in
                                pagerPayload = .init(posts: selectedPosts, startIndex: 0)
                            }
                            .padding(.top, -16)

                        }
                        .padding(.trailing, 10)
                    }
                    
                    HStack(spacing: 34) {
                        Button {
                        } label: {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                                .frame(width: 68, height: 68)
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
                                .font(.system(size: 23))
                                .foregroundColor(.black)
                                .frame(width: 68, height: 68)
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
                            KFImage(url)
                                .placeholder {                         
                                    ProgressView()
                                }
                                .fade(duration: 0.25)
                                .cancelOnDisappear(true)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(22)
                                .shadow(radius: 10)
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
struct StreakChip: View {
    let count: Int
    
    var body: some View {
        let todayColor: Color = {
            if let uid = AuthManager.shared.user?.uid {
                return colorForToday(date: Date(), uid: uid)
            } else {
                return .black
            }
        }()
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(count)")
                    .font(.system(size: 30, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                
                Text("day streak🔥")
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                
            }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 6)
    }
}

struct HueRingInteractive: View {
    let buckets: [HueBucket]
    var diameter: CGFloat = 200
    var ringWidth: CGFloat = 22
    var onSelect: (_ posts: [IMagepost]) -> Void

    private var maxCount: Int { buckets.map { $0.posts.count }.max() ?? 0 }

    var body: some View {
        ZStack {
            // 背景：色相リング
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: stride(from: 0.0, through: 1.0, by: 0.01)
                            .map { Color(hue: $0, saturation: 1, brightness: 1) }),
                        center: .center
                    ),
                    lineWidth: ringWidth
                )
                .frame(width: diameter, height: diameter)
                .overlay(
                    Circle().stroke(Color.black.opacity(0.10), lineWidth: 1)
                        .frame(width: diameter, height: diameter)
                )

            // マーカー & 件数バッジ & タップ領域（ビン単位）
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
                let outerR = diameter/2
                let innerR = outerR - ringWidth
                let midR   = (outerR + innerR)/2
                let N = buckets.count
                let step = 2 * Double.pi / Double(N)

                ForEach(buckets) { b in
                    let count = b.posts.count
                    let theta = (Double(b.index) + 0.5) * step

                    if count > 0 {
                        // 0..1 に正規化
                        let t = Double(count) / Double(max(maxCount, 1))

                        // 濃さ（白の不透明度）を 0.25～0.9 でマッピング
                        let opacity = 0.25 + 0.65 * t

                        let d: CGFloat = 16

                        // リングの真ん中線上に配置（少し内側にしたければ midR - 8 など）
                        let badgeR = midR
                        let bx = center.x + CGFloat(cos(theta)) * badgeR
                        let by = center.y + CGFloat(sin(theta)) * badgeR

                        Circle()
                            .fill(Color.white.opacity(opacity))
                            .frame(width: d, height: d)
                            // 色を加算気味に見せたいなら下の1行を有効化（好みで）
                            // .blendMode(.plusLighter)
                            .position(x: bx, y: by)
                            .accessibilityLabel("\(count) posts")
                    }

                    // タップ領域はそのまま
                    let start = Double(b.index) * step
                    let end   = start + step
                    Path { p in
                        p.addArc(center: center, radius: midR, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
                        p.addArc(center: center, radius: innerR, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
                        p.closeSubpath()
                    }
                    .fill(Color.clear)
                    .contentShape(Path { p in
                        p.addArc(center: center, radius: outerR, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
                        p.addArc(center: center, radius: innerR, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
                        p.closeSubpath()
                    })
                    .onTapGesture {
                        if !b.posts.isEmpty { onSelect(b.posts) }
                    }
                    .accessibilityAddTraits(.isButton)
                }
            }
            .allowsHitTesting(true)
        }
        .frame(width: diameter + 3, height: diameter + 3)
    }
}

//#Preview {
//    HomeView(year: 2025, month: 8)
//}
