//
//  ContentView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/04/29.
//

import SwiftUI

struct ContentView: View {
    // Get the current year and month
    private let year: Int
    private let month: Int
    
    init() {
        // Get the current date's components
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        
        // Safely assign the year and month, providing a default value if they are nil
        self.year = components.year ?? 2025
        self.month = components.month ?? 9
    }
    
    var body: some View {
        HomeView(year: year, month: month)
    }
}
