//
//  SimpleCameraView.swift
//  SimpleCamera
//
//  Created by Yuki Kuwashima on 2024/11/09.
//

import SwiftUI

public struct SimpleCameraView: View {

    @Binding var trigger: Trigger
    let onTakePhoto: (UIImage) async -> ()
    @State var vc = CameraViewController()

    public init(trigger: Binding<Trigger>, _ onTakePhoto: @escaping (UIImage) async -> ()) {
        self.onTakePhoto = onTakePhoto
        self._trigger = trigger
    }

    public var body: some View {
        CameraView(vc: vc) { image in
            await onTakePhoto(image)
        }
        .onChange(of: trigger) {
            vc.takePhoto()
        }
    }
}
