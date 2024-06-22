//
//  CameraViewModel.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//
import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Photos

class CameraViewModel: NSObject, ObservableObject {
    enum PhotoCaptureState {
        case notStarted
        case processing
        case finished(Data)
    }
    
    @Published var timeSet: Int = 0
    var timer: Timer?
    var onCountdownUpdate: ((Int) -> Void)?
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCapturePhotoOutput()
    
    @Published var photoCaptureState: PhotoCaptureState = .notStarted
    @Published var isShowingPhotoViewer = false
    @Published var thumbnailImage: UIImage?
    
    var photoData: Data? {
        if case .finished(let data) = photoCaptureState {
            return data
        }
        return nil
    }
    
    var hasPhoto: Bool { photoData != nil }
    
    func requestAccessAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { didAllowAccess in
                if didAllowAccess {
                    self.setup()
                }
            }
        case .authorized:
            setup()
        default:
            print("Camera access denied")
        }
    }
    
    private func setup() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        do {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            preview.videoGravity = .resizeAspectFill
            preview.session = session
            
            session.commitConfiguration()
            session.startRunning()
        } catch {
            print("Failed to set up camera: \(error.localizedDescription)")
        }
    }
    
    func startTimer() {
        guard timeSet > 0 else {
            takePhoto()
            return
        }
        
        var countdown = timeSet
        onCountdownUpdate?(countdown)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            countdown -= 1
            self?.onCountdownUpdate?(countdown)
            
            if countdown <= 0 {
                timer.invalidate()
                self?.takePhoto()
            }
        }
    }
    
    func takePhoto() {
        guard case .notStarted = photoCaptureState else { return }
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
        
        withAnimation {
            photoCaptureState = .processing
        }
    }
    
    var isFlashOn = false

    func toggleFlash() {
        guard let device = getCurrentCameraDevice() else { return }
        do {
            if device.hasTorch {
                try device.lockForConfiguration()
                device.torchMode = isFlashOn ? .off : .on
                isFlashOn.toggle()
                device.unlockForConfiguration()
            }
        } catch {
            print("Device torch flash error: \(error.localizedDescription)")
        }
    }
    
    func focus(at point: CGPoint) {
        guard let device = getCurrentCameraDevice() else { return }
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {
            print("Focus configuration error: \(error.localizedDescription)")
        }
    }
    
    private func getCurrentCameraDevice() -> AVCaptureDevice? {
        return (session.inputs.first as? AVCaptureDeviceInput)?.device
    }
    
    private func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                print("Photo saved to gallery")
            } else if let error = error {
                print("Error saving photo: \(error.localizedDescription)")
            }
        })
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get image data")
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            print("Failed to create UIImage from image data")
            return
        }
        
        saveImageToGallery(image)
        
        DispatchQueue.main.async {
            withAnimation {
                self.photoCaptureState = .finished(imageData)
                self.thumbnailImage = image
            }
            // Setelah foto diambil, kamera siap untuk pengambilan foto berikutnya
            self.retakePhoto()
        }
    }
    
    func retakePhoto() {
        withAnimation {
            photoCaptureState = .notStarted
        }
    }
}
