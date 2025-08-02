//
//  CameraViewController.swift
//  SimpleCamera
//
//  Created by Yuki Kuwashima on 2024/11/09.
//

import UIKit
import AVFoundation
import SwiftData
import SwiftUI

public class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var capturesession: AVCaptureSession!
    var cameraoutput: AVCapturePhotoOutput!
    var previewlayer: AVCaptureVideoPreviewLayer!
    var onTakePhoto: ((UIImage) async -> ())?

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        capturesession = AVCaptureSession()
        cameraoutput = AVCapturePhotoOutput()
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if capturesession.canAddInput(input) && capturesession.canAddOutput(cameraoutput) {
                capturesession.addInput(input)
                capturesession.addOutput(cameraoutput)
                previewlayer = AVCaptureVideoPreviewLayer(session: capturesession)
                previewlayer.frame = view.bounds
                previewlayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewlayer)
                Task.detached {
                    await self.capturesession.startRunning()
                }
            }
        } catch {
            print(error)
        }
    }

    public func takePhoto() {
        let settings = AVCapturePhotoSettings()
        cameraoutput.capturePhoto(with: settings, delegate: self)
    }

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imagedata = photo.fileDataRepresentation() {
            guard let image = UIImage(data: imagedata) else {
                return
            }
            Task {
                await onTakePhoto?(image)
            }
        }
    }
}
