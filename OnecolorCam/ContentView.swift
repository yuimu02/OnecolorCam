//
//  ContentView.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/04/29.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.displayScale) private var displayScale

    @State var imageData: Data?
    @State var updateCounter = 0

    @State var hueToDisplay: Float = 0.5
    @State var range: Float = 0.1
    
    @State var color: Color = .red
    
    var body: some View {
        Button("update") {
            updateCounter += 1
        }
        Slider(value: $hueToDisplay, in: 0...1)
        Slider(value: $range, in: 0...1)
        Renderable(updateCounter: $updateCounter, renderedData: $imageData) {
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
                            .color(color),
                        ]
                    )
                )
        }
        if let imageData {
            Image(uiImage: UIImage(data: imageData)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

}

public struct Renderable<V: View>: View {

    @Environment(\.displayScale) private var displayScale

    @Binding var updateCounter: Int
    @Binding var renderedData: Data?
    let view: () -> V

    public init(
        updateCounter: Binding<Int>,
        renderedData: Binding<Data?>,
        @ViewBuilder _ view: @escaping () -> V
    ) {
        self._updateCounter = updateCounter
        self._renderedData = renderedData
        self.view = view
    }

    public var body: some View {
        view()
            .onChange(of: updateCounter) {
                renderedData = render()
            }
    }

    @MainActor
    func render() -> Data? {
        let renderer = ImageRenderer(
            content: view()
        )
        renderer.scale = displayScale
        return renderer.uiImage?.pngData()
    }
}

#Preview {
    ContentView()
}
