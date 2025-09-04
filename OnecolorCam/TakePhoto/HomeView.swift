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
//    var color: String
}

struct HomeView: View {
    let year: Int
    let month: Int
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(AuthManager.self) var authManager
    @State private var currentTab: Tab = .home
    @State var images: [IMagepost] = []
    @State private var isShowingDetailSheet = false
    @State private var selectedImagePost: IMagepost?
    
    
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
    private func findImagePost(for day: Int) -> IMagepost? {
        let calendar = Calendar.current
        // Create a target date for the specific day in the current month and year
        guard let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            return nil
        }
        
        // Find the first image where the creation date is on the same day as the target date
        return images.first { imagePost in
            calendar.isDate(imagePost.created, inSameDayAs: targetDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                ColorfulView(color: $viewModel.colors)
                    .ignoresSafeArea()
                
                VStack {
                    Text(viewModel.formattedDate)
                        .font(.system(size: 20))
                        .padding()
                        .foregroundColor(.black)
                    
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
                                    if let imagePost = findImagePost(for: day), let url = URL(string: imagePost.URLString) {
                                        // If a URL exists, display the image
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                .clipped()
                                                .onTapGesture {
                                                    self.selectedImagePost = imagePost
                                                    self.isShowingDetailSheet = true
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
                    
                    // Bottom navigation buttons
                    HStack(spacing: 34) {
                        NavigationLink(destination: HomeView(year: 2025, month: 8)) {
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
                        .disabled(currentTab == .home)
                        
                        NavigationLink(destination: TakePhotoView()) {
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
                        
                        NavigationLink(destination: OthersPostsView()) {
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
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .onAppear {
                viewModel.updateDate()
                Task {
                    try? await loadAllImages()
                }
            }
            .sheet(isPresented: $isShowingDetailSheet) {
                if let post = selectedImagePost {
                    ImageDetailSheet(imageURL: post.URLString, date: post.created)
                }
            }
            .refreshable {
                Task {
                    try? await loadAllImages()
                }
            }
        }
    }
    
    func loadAllImages() async throws {
        // Ensure user is not nil before fetching
        guard let uid = AuthManager.shared.user?.uid else { return }
        self.images = try await FirebaseManager.getAllItems(uid: uid)
    }
}

struct ImageDetailSheet: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) var dismiss
    let imageURL: String?
    let date: Date?

//    var formattedDate: String {
//        guard let date = date else { return "" }
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//        formatter.locale = Locale.current
//        return formatter.string(from: date)
//    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
            }

            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text("画像がありません")
            }

            Text(viewModel.formattedDate)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
        }
        .padding()
    }
}

struct GlassRect: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(.ultraThinMaterial)
            .aspectRatio(1, contentMode: .fit) // This helps ensure the cell is a square
    }
}

#Preview {
    HomeView(year: 2025, month: 8)
}
