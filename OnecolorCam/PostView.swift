//
//  PostView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/21.
//

import SwiftUI
import ColorfulX

struct PostView: View {
    @State var colors: [Color] = []
    var body: some View {
        ZStack {
            Color.white
            ColorfulView(color: $colors)
                .ignoresSafeArea()
                .opacity(0.7)
            VStack {
                       
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                            Image("sample")
            }
        }
        .onAppear {
            colors = getNearColors(todaysColor: .pink)
        }
    }
    
    func getNearColors(todaysColor: Color) -> [Color] {
        let todayColorRGB = todaysColor.getRGB()
        let colorNear1 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.3...0)),
            green: Double(todayColorRGB.g + Float.random(in: -0.3...0)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.3...0)),
        )
        let colorNear2 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.2...0.2)),
            green: Double(todayColorRGB.g + Float.random(in: -0.2...0.2)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.2...0.2)),
        )
        let colorNear3 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.3...0.3)),
            green: Double(todayColorRGB.g + Float.random(in: -0.3...0.3)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.3...0.3)),
        )
        let colorNear4 = Color(
            red: Double(todayColorRGB.r + Float.random(in: -0.3...0.3)),
            green: Double(todayColorRGB.g + Float.random(in: -0.3...0.3)),
            blue: Double(todayColorRGB.b + Float.random(in: -0.3...0.3)),
        )
        return [todaysColor, colorNear1, colorNear2, colorNear3, colorNear4]
    }
   
}

#Preview {
    ContentView()
}
