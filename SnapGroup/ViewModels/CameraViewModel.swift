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

@Observable
class CameraViewModel: NSObject {
    enum PhotoCaptureState {
        case notStarted
        case processing
        case finished (Data)
    }
    
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCapturePhotoOutput()
    var timeSet = 0
    var isCountingDown = false
    
    var photoData: Data? {
        if case .finished(let data) = photoCaptureState {
            return data
        }
        return nil
    }
    
    var hasPhoto: Bool {photoData != nil}

    private (set) var photoCaptureState: PhotoCaptureState = .notStarted
    
    var onCountdownUpdate: ((Int?) -> Void)?
    
    private var countdownWorkItem: DispatchWorkItem?
    
    func requestAccessAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { didAllowAccess in
                self.setup()
            }
        case .authorized:
            setup()
        default:
            print ("other status")
        }
    }
    
    private func setup() {
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        do {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(input) else { return }
            session.addInput(input)
            
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            
            session.commitConfiguration()
            
            Task(priority: .background) {
                self.session.startRunning()
                await MainActor.run {
                    self.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func takePhoto() {
        let capturePhoto = {
            guard case .notStarted = self.photoCaptureState else { return }
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            withAnimation {
                self.photoCaptureState = .processing
            }
        }

        if timeSet != 0 {
            self.isCountingDown = true
            startCountdown(duration: timeSet) {
                if self.isCountingDown { // Ensure countdown completed without cancellation
                    capturePhoto()
                    self.isCountingDown = false
                }
            }
        } else {
            capturePhoto()
        }
    }
    
    private func startCountdown(duration: Int, completion: @escaping () -> Void) {
        // Cancel any existing countdown work item
        countdownWorkItem?.cancel()
        
        countdownWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            for i in (1...duration).reversed() {
                // Check if the countdown has been cancelled
                if self.countdownWorkItem?.isCancelled ?? true {
                    break
                }
                
                DispatchQueue.main.async {
                    self.onCountdownUpdate?(i)
                }
                
                // Wait for 1 second before updating countdown (adjust as needed)
                Thread.sleep(forTimeInterval: 1.0)
            }
            
            DispatchQueue.main.async {
                self.onCountdownUpdate?(nil)
                completion()
            }
        }
        
        // Start the countdown work item
        DispatchQueue.global().async(execute: countdownWorkItem!)
    }
    
    func retakePhoto() {
        Task(priority: .background) {
            self.session.startRunning()
            await MainActor.run {
                self.photoCaptureState = .notStarted
            }
        }
    }

    func cancelCapturePhoto() {
        self.isCountingDown = false
        countdownWorkItem?.cancel()
        countdownWorkItem = nil
        self.onCountdownUpdate?(nil)
        withAnimation {
            if case .processing = self.photoCaptureState {
                self.photoCaptureState = .notStarted
            }
        }

    }

    var isFlashOn = false

    func toggleFlash() {
        guard let device = getCurrentCameraDevice() else { return }
        do {
            if device.hasTorch {
                try device.lockForConfiguration()
                if isFlashOn {
                    device.torchMode = .off
                } else {
                    device.torchMode = .on
                }
                isFlashOn.toggle()
                device.unlockForConfiguration()
            }
        } catch {
            // Handle errors (disable flash button, log error, etc.)
            print("Device torch Flash Error: \(error.localizedDescription)")
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
    
    func getCurrentCameraDevice() -> AVCaptureDevice? {
        return (session.inputs.first as? AVCaptureDeviceInput)?.device
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print(error.localizedDescription)
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        guard let provider = CGDataProvider(data: imageData as CFData) else { return }
        guard let cgImage = CGImage (jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        let capturedImage = UIImage(data: imageData)
        if let image = capturedImage {
            saveImageToGallery(image)
        }
        Task(priority: .background) {
            self.session.stopRunning()
            await MainActor.run {
                
                let image = UIImage (cgImage: cgImage, scale: 1, orientation: UIDevice.current.orientation.uiImageOrientation)
                let imageData = image.pngData()
                
                withAnimation {
                    if let imageData {
                        self.photoCaptureState = .finished(imageData)
                    } else {
                        print("error occurred")
                    }
                }
            }
            
        }
    }
    func saveImageToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        })                   // allert kalau sudah disimpan
//        { success, error in
//            if success {
//                DispatchQueue.main.async {
//                    self.alertMessage = "Your photo has been saved to the gallery."
//                    self.showAlert = true
//                }
//            } else if let error = error {
//                DispatchQueue.main.async {
//                    self.alertMessage = "Error saving photo: \(error.localizedDescription)"
//                    self.showAlert = true
//                }
//            }
//        }
    }
}
