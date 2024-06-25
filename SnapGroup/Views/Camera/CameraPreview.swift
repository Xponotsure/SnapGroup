//
//  CameraPreview.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI
import AVFoundation
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraVM: CameraViewModel
    let frame: CGRect
    
    @Binding var focusPoint: CGPoint
    @Binding var showFocusIndicator: Bool
    
    class Coordinator: NSObject {
        var parent: CameraPreview
        private var initialZoomFactor: CGFloat = 1.0
        init(parent: CameraPreview) {
              self.parent = parent
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
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: frame)
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
               view.addGestureRecognizer(pinchGesture)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
        cameraVM.preview = AVCaptureVideoPreviewLayer(session: cameraVM.session)
        cameraVM.preview.frame = frame
        cameraVM.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraVM.preview)
        
        let previewWidth = frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let previewWidth = frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
        cameraVM.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
    }
}

