// HomeView.swift

import SwiftUI
import ColorfulX
import AppleSignInFirebase
import FirebaseFirestore

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
    
    
    private var days: [Int?] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Start on Sunday
        
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
            .sorted { $0.created < $1.created }
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
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        if let uid = AuthManager.shared.user?.uid {
                            Circle()
                                .fill(colorForToday(date: Date(), uid: uid)) // 今日の色
                                .frame(width: 17, height: 17)                 // 丸の大きさ
                            //                                .overlay(
                            //                                    Circle().stroke(Color.black.opacity(0.1), lineWidth: 1)
                            //                                )
                        }
                    }
                    .padding(.top, 45)
                    .padding(.bottom, 14)
                    .padding()
                    
                    HStack(spacing: 2) {
                        let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                        ForEach(weekDays, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // MARK: - Modified Calendar Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                        ForEach(days.indices, id: \.self) { index in
                            ZStack {
                                GlassRect()
                                
                                if let day = days[index] {
                                    let posts = findImagePost(for: day)
                                    if let first = posts.first, let url = URL(string: first.URLString) {
                                        // If a URL exists, display the image
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                .clipped()
                                                .onTapGesture {
                                                    postsForSelectedDay = posts
                                                    startIndex = 0
                                                    isShowingPager = true
                                                }
                                        } placeholder: {
                                            ProgressView() // Show a loading indicator
                                        }
                                        .clipped() // Prevents the image from overflowing its frame
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        
                                    } else {
                                        // If no image, display the day number
                                        Text("\(day)")
                                            .foregroundColor(.black)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                            }
                            .padding(.vertical, 3)
                        }
                    }
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 23) {
                            ForEach(images.sorted { $0.created > $1.created }, id: \.id) { post in
                                if let url = URL(string: post.URLString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .cornerRadius(12)
                                            .shadow(radius: 4)
                                            .onTapGesture {
                                                // タップしたら詳細シートを出す
                                                postsForSelectedDay = [post]
                                                startIndex = 0
                                                isShowingPager = true
                                            }
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 120, height: 120)
                                    }
                                }
                            }
                        }
                        //                        .padding(.horizontal)
                    }
                    .frame(height: 150)
                    .padding(.horizontal, -16)
                    .padding(.top, 33)
                    
                    // Bottom navigation buttons
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
                    .padding(.vertical, 30)
                }
                .padding()
            }
            .onAppear {
                viewModel.updateDate()
                Task {
                    Task { await loadAllImagesMixed()}
                }
            }
            .sheet(isPresented: $isShowingPager) {
                ImageDetailPagerSheet(posts: postsForSelectedDay, index: startIndex)
            }
            .refreshable {
                Task {
                    await loadAllImagesMixed()
                }
            }
        }
    }
    
    //    func loadAllPrivateImages() async throws {
    //        // Ensure user is not nil before fetching
    //        guard let uid = AuthManager.shared.user?.uid else { return }
    //        self.images = try await FirebaseManager.getAllPrivateItems(uid: uid)
    //    }
    //}
    
    @MainActor
    func loadAllImagesMixed() async {
        guard let uid = AuthManager.shared.user?.uid else { return }
        do {
            async let priv = FirebaseManager.getAllPrivateItems(uid: uid)
            async let pub  = FirebaseManager.getAllPublicItems()
            let (privateItems, publicItems) = try await (priv, pub)
            
            let merged = privateItems + publicItems
            
            // 重複除去（id があれば id を、無ければ URLString をキーに）
            var seen = Set<String>()
            let unique = merged.filter { p in
                let key = p.id ?? p.URLString
                return seen.insert(key).inserted
            }
            
            self.images = unique.sorted { $0.created > $1.created }
        } catch {
            print("loadAllImagesMixed error:", error)
        }
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
                        Text(Self.df.string(from: posts[i].created))
                            .font(.title3).bold()
                            .padding(.top,50)
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
            .aspectRatio(1, contentMode: .fit) // This helps ensure the cell is a square
    }
}

//#Preview {
//    HomeView(year: 2025, month: 8)
//}
