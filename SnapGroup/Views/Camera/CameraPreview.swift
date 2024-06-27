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
//    let frame: CGRect
    
    @Binding var focusPoint: CGPoint
    @Binding var showFocusIndicator: Bool
    
    class Coordinator: NSObject {
        var parent: CameraPreview
        private var initialZoomFactor: CGFloat = 1.0
        init(parent: CameraPreview) {
            self.parent = parent
            super.init()

        }   
//          @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
//                   guard let device = self.parent.cameraVM.getCurrentCameraDevice() else { return }
//                   if sender.state == .changed {
//                     let newScaleFactor = min(max(1.0, sender.scale * device.videoZoomFactor), device.activeFormat.videoMaxZoomFactor)
//                     self.parent.cameraVM.setZoom(scale: newScaleFactor)
//                 }
//             }
        
        @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
                    guard let device = self.parent.cameraVM.getCurrentCameraDevice() else { return }
                    switch sender.state {
                    case .began:
                        initialZoomFactor = device.videoZoomFactor
                    case .changed:
                        let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
                        let newScaleFactor = min(max(1.0, initialZoomFactor * sender.scale), maxZoomFactor)
                        let smoothZoomFactor = (device.videoZoomFactor + newScaleFactor) / 2.0
                        self.parent.cameraVM.setZoom(scale: smoothZoomFactor)
                    default:
                        break
                    }
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
    
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        cameraVM.setupPreviewLayer(in: viewController.view)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        viewController.view.addGestureRecognizer(pinchGesture)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        viewController.view.addGestureRecognizer(tapGesture)
        
        
        
        cameraVM.preview = AVCaptureVideoPreviewLayer(session: cameraVM.session)
        cameraVM.preview.frame = viewController.view.bounds
        cameraVM.preview.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(cameraVM.preview)
        
        let previewWidth = viewController.view.frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (viewController.view.frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)


        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        let previewWidth = uiViewController.view.frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (uiViewController.view.frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
        cameraVM.preview.connection?.videoRotationAngle = 90
    }

}

