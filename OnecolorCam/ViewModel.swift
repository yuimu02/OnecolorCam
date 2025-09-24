//
//  ViewModel.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/23.
//
import SwiftUI
import Foundation

class HomeViewModel: ObservableObject {
    @Published var hueToDisplay: Float = 0.5
    @Published var range: Float = 1.0
    //    @Published var color: Color = .red
    @Published var takenPhoto: UIImage? = nil
    @Published var showNextView: Bool = false
    //    @Published var colors: [Color] = [Color.blue, Color.purple, Color.white]
    @Published var formattedDate: String = ""
    @Published var colors: [Color] = []
    
    init() {
        updateDate()
        updateColors(todaysColor: colorForToday(date: Date(), uid: "hgursnsnfuesfnfs"))
    }
    
    func updateDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy.MM.dd.E"
        formattedDate = formatter.string(from: Date())
    }
    
    func selectColor(hue: Float, range: Float) {
        self.hueToDisplay = hue
        self.range = range
    }
    
    func resetColorRange() {
        self.range = 1.0
    }
    
    
    func updateColors(todaysColor: Color) {
        colors = getNearColors(todaysColor: todaysColor)
    }
    
    private func getNearColors(todaysColor: Color) -> [Color] {
        let todayColorRGB = todaysColor.getRGB()
        let colorNear1 = Color.white
        let colorNear2 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.4...0.3)),
            green: Double(todayColorRGB.g + Float.random(in: -0.4...0.3)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.2...0.2))
        )
        let colorNear3 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.3...0.3)),
            green: Double(todayColorRGB.g + Float.random(in: -0.3...0.3)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.3...0.3))
        )
        let colorNear4 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.3...0.3)),
            green: Double(todayColorRGB.g + Float.random(in: -0.3...0.3)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.3...0.3))
        )
        return [todaysColor, colorNear1, colorNear2, colorNear3, colorNear4]
    }
    
    struct TabBarButton: View {
        let iconName: String
        let destinationView: any View
        let isDisabled: Bool
        
        var body: some View {
            NavigationLink(destination: AnyView(destinationView)) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.black)
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .disabled(isDisabled)
        }
    }
}
