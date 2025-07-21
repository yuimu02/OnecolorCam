//
//  ContentView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/04/29.
//

import SwiftUI
import SimpleCamera
import Colorful

struct ContentView: View {
    @Environment(\.displayScale) private var displayScale
    
    @State var imageData: Data?
    @State var updateCounter = 0
    
    @State var hueToDisplay: Float = 0.5
    @State var range: Float = 1.0
    
    @State var color: Color = .red
    
    @State var takenPhoto: UIImage?
    
    @State var showNextView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("赤") {
                        hueToDisplay = 0.99
                        range = 0.1
                    }
                    Button("緑") {
                        hueToDisplay = 0.33
                        range = 0.13
                    }
                    Button("青") {
                        hueToDisplay = 0.66
                        range = 0.08
                    }
                    Button("元に戻す") {
                        range = 1.0
                    }
                }
                .padding()
                
                Image("Sample")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorEffect(
                        Shader(
                            function: ShaderFunction(
                                library: .bundle(.main),
                                name: "sample"
                            ),
                            arguments: [
                                .float(hueToDisplay),
                                .float(range),
                                .color(color)
                            ]
                        )
                    )
                Button("trst") {
                    showNextView = true
                }
            }
            .navigationDestination(isPresented: $showNextView) {
                Text("aiueo")
                SimpleCameraView { uiimage, dismissAction in
                    takenPhoto = uiimage
                }
            }
            .sheet(
                isPresented: Binding {
                    takenPhoto != nil
                } set: { _ in
                    takenPhoto = nil
                }
            ) {
                if let takenPhoto {
                    Image(uiImage: takenPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            
        }
    }
}


#Preview {
    ContentView()
}
