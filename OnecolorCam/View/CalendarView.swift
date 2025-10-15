//
//  CalendarView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/09/25.
//

import SwiftUI
import AppleSignInFirebase

struct MonthCalendarGrid: View {
    let monthDate: Date
    let images: [IMagepost]
    let onTapDayPosts: (_ posts: [IMagepost]) -> Void
    let todayColor: Color = {
        if let uid = AuthManager.shared.user?.uid {
            return colorForToday(date: Date(), uid: uid)
        } else {
            return .black
        }
    }()

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1 // Sunday
        return c
    }

    private var yearMonth: (year: Int, month: Int) {
        let comp = calendar.dateComponents([.year, .month], from: monthDate)
        return (comp.year!, comp.month!)
    }

    private var days: [Int?] {
        let comps = DateComponents(year: yearMonth.year, month: yearMonth.month, day: 1)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }

        let numDays = range.count
        let weekday = calendar.component(.weekday, from: firstDay)

        var result: [Int?] = Array(repeating: nil, count: weekday - 1)
        result.append(contentsOf: (1...numDays).map { Optional($0) })
        while result.count < 42 { result.append(nil) }
        return result
    }

    private func findImagePosts(for day: Int) -> [IMagepost] {
        let comps = DateComponents(year: yearMonth.year, month: yearMonth.month, day: day)
        guard let targetDate = calendar.date(from: comps) else { return [] }
        return images
            .filter { calendar.isDate($0.created, inSameDayAs: targetDate) }
            .sorted { $0.created > $1.created }
    }

    var body: some View {
        VStack(spacing: 10) {
            // 曜日ヘッダ
            HStack(spacing: 2) {
                let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
                }
            }

            // カレンダー本体
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(days.indices, id: \.self) { index in
                    ZStack {
                        GlassRect()

                        if let day = days[index] {
                            let posts = findImagePosts(for: day)
                            if let first = posts.first,
                               let url = URL(string: first.URLString) {
                                AsyncImage(url: url) { image in
                                    ZStack(alignment: .topLeading) {
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fit)
                                        DateBadge(day: day)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .onTapGesture { onTapDayPosts(posts) }
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            } else {
                                Text("\(day)")
                                    .foregroundColor(.black)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(todayColor.opacity(0.3), lineWidth: 1.2)
                    )
                    .padding(.vertical, 3)
                }
            }
        }
    }
}

struct MonthPager: View {
    let images: [IMagepost]
    let onTapDayPosts: (_ posts: [IMagepost]) -> Void
    let todayColor: Color = {
        if let uid = AuthManager.shared.user?.uid {
            return colorForToday(date: Date(), uid: uid)
        } else {
            return .black
        }
    }()

    private let calendar = Calendar(identifier: .gregorian)
    private let months: [Date]
    private let centerIndex: Int
    @State private var index: Int

    init(images: [IMagepost],
         onTapDayPosts: @escaping (_ posts: [IMagepost]) -> Void) {
        self.images = images
        self.onTapDayPosts = onTapDayPosts

        // 今月の1日
        let base = Calendar.current.date(from:
            Calendar.current.dateComponents([.year, .month], from: Date()))!

        // -60〜+59ヶ月（必要に応じて増減OK）
        let spanHalf = 60
        self.months = (-spanHalf..<spanHalf).compactMap {
            Calendar.current.date(byAdding: .month, value: $0, to: base)
        }
        self.centerIndex = spanHalf
        _index = State(initialValue: centerIndex)
    }

    private func title(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = calendar
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                Text(title(for: months[index]))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: todayColor.opacity(0.9), radius: 1, x: 0, y: 0)
            }

            TabView(selection: $index) {
                ForEach(months.indices, id: \.self) { i in
                    MonthCalendarGrid(monthDate: months[i], images: images) { posts in
                        onTapDayPosts(posts)
                    }
                    .tag(i)
                }
            }
            .frame(height: 360)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}


