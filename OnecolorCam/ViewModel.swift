//
//  ViewModel.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/23.
//
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var hueToDisplay: Float = 0.5
    @Published var range: Float = 1.0
    @Published var color: Color = .red
    @Published var takenPhoto: UIImage? = nil
    @Published var showNextView: Bool = false
    @Published var colors: [Color] = [Color.blue, Color.purple, Color.white]
    
    @Published var dateText: String = ""
    
    private let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd(E)"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        updateDate()
    }
    
    func updateDate() {
        dateText = dateFormatter.string(from: Date())
    }
    
    func selectColor(hue: Float, range: Float) {
        self.hueToDisplay = hue
        self.range = range
    }
    
    func resetColorRange() {
        self.range = 1.0
    }
    
    
}
