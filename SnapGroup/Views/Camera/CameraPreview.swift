//
//  CameraPreview.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI
import AVFoundation
struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var cameraVM: CameraViewModel
    let frame: CGRect
    
    @Binding var focusPoint: CGPoint
    @Binding var showFocusIndicator: Bool
    
    class Coordinator: NSObject {
        var parent: CameraPreview

        init(parent: CameraPreview) {
            self.parent = parent
            super.init()

        }

        @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            let frameSize = gesture.view?.frame.size ?? CGSize.zero
            let focusPoint = CGPoint(x: location.y / frameSize.height, y: 1.0 - location.x / frameSize.width)

            parent.focusPoint = location
            parent.showFocusIndicator = true
            parent.cameraVM.focus(at: focusPoint)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: frame)
//        
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
//        view.addGestureRecognizer(tapGesture)
//        
//        cameraVM.preview = AVCaptureVideoPreviewLayer(session: cameraVM.session)
//        cameraVM.preview.frame = frame
//        cameraVM.preview.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(cameraVM.preview)
//        
//        let previewWidth = frame.width
//        let previewHeight = previewWidth * 4 / 3
//        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
//
//        return view
//    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        cameraVM.setupPreviewLayer(in: viewController.view)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        viewController.view.addGestureRecognizer(tapGesture)
        
        cameraVM.preview = AVCaptureVideoPreviewLayer(session: cameraVM.session)
        cameraVM.preview.frame = frame
        cameraVM.preview.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(cameraVM.preview)
        
        let previewWidth = frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)


        
        return viewController
    }

    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        let previewWidth = frame.width
//        let previewHeight = previewWidth * 4 / 3
//        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
//        cameraVM.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
//    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        if let previewLayer = cameraVM.preview {
//            previewLayer.frame = uiViewController.view.bounds
//        }
        
        let previewWidth = frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
        cameraVM.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle

    }

}

