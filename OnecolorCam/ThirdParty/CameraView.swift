//
//  CameraView.swift
//  SimpleCamera
//
//

import Foundation
import SwiftUI
import UIKit

public struct CameraView: UIViewControllerRepresentable {
    let vc: CameraViewController
    public init(vc: CameraViewController, onTakePhoto: @escaping (UIImage) async -> ()) {
        self.vc = vc
        vc.onTakePhoto = onTakePhoto
    }
    public func makeUIViewController(context: Context) -> CameraViewController {
        vc
    }
    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {

    }
}
