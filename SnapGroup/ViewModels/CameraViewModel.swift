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
import Vision

class CameraViewModel: NSObject, ObservableObject {
    enum PhotoCaptureState {
        case notStarted
        case processing
        case finished(Data)
    }
    
    var timeSet: Int = 0
    var timer: Timer?
    var onCountdownUpdate: ((Int?) -> Void)?
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var photoOutput = AVCapturePhotoOutput()
    var videoOutput = AVCaptureVideoDataOutput()
    private var faceDetectionRequest: VNDetectFaceRectanglesRequest!
    
    @Published var photoCaptureState: PhotoCaptureState = .notStarted
    @Published var isUsingFrontCamera = false
    @Published var detectedFaces: [VNFaceObservation] = []
    
//    @Published var path: [CGRect] = []

    @Published var isCountingDown = false
    
    
    var photoData: Data? {
        if case .finished(let data) = photoCaptureState {
            return data
        }
        return nil
    }
    
    var hasPhoto: Bool { photoData != nil }
    
    private var countdownWorkItem: DispatchWorkItem?
    
    
    override init() {
        super.init()
        requestAccessAndSetup()
        setupFaceDetection()
    }

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
            let device = isUsingFrontCamera ? frontCameraDevice() : backCameraDevice()
            guard let device = device else { return }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            for input in session.inputs {
                session.removeInput(input)
            }
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        } catch {
            print("Failed to set up camera: \(error.localizedDescription)")
        }
    }
    
    func switchCamera() {
        isUsingFrontCamera.toggle()
        session.stopRunning()
        session.inputs.forEach { session.removeInput($0) }
        setup()
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
                    self?.onCountdownUpdate?(nil) // Set countdown to nil after timer finishes
                    self?.takePhoto()
                }
            }
        }

    
    func takePhoto() {
         let capturePhoto = {
             guard case .notStarted = self.photoCaptureState else { return }
             self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
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
    
    @Published var isFlashOn = false

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
    
    func getCurrentCameraDevice() -> AVCaptureDevice? {
        return (session.inputs.first as? AVCaptureDeviceInput)?.device
    }
    
//    private func frontCameraDevice() -> AVCaptureDevice? {
//        return AVCaptureDevice.devices().first { $0.position == .front }
//    }
//    
//    private func backCameraDevice() -> AVCaptureDevice? {
//        return AVCaptureDevice.devices().first { $0.position == .back }
//    }
    
    private func frontCameraDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        return discoverySession.devices.first
    }

    private func backCameraDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )
        return discoverySession.devices.first
    }
    
    func setZoom(scale: CGFloat) {
            guard let device = getCurrentCameraDevice() else { return }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = max(1.0, min(device.activeFormat.videoMaxZoomFactor, scale))
                device.unlockForConfiguration()
            } catch {
                print("Zoom configuration error: \(error.localizedDescription)")
            }
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
    
    func setupPreviewLayer(in view: UIView) {
        preview.session = session
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
    }

    
    private func setupFaceDetection() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] (request, error) in
            if let results = request.results as? [VNFaceObservation] {
                DispatchQueue.main.async {
                    self?.detectedFaces = results
                }
            }
        }
    }
    
    func convertBoundingBox(_ boundingBox: CGRect, screenSize: CGSize) -> CGRect {
        return CGRect(
            x: boundingBox.minX * screenSize.width,
            y: (1 - boundingBox.maxY) * screenSize.height,
            width: boundingBox.width * screenSize.width,
            height: boundingBox.height * screenSize.height
        )
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, screenSize: CGSize) {
           guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
           let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
           try? requestHandler.perform([faceDetectionRequest])
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
            }
            self.retakePhoto()
        }
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let screenSize = preview.frame.size
        processSampleBuffer(sampleBuffer, screenSize: screenSize)
    }
    
}
  
class PhotoLibraryViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var recentPhotos: [UIImage] = []
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: PHAsset.fetchAssets(with: .image, options: nil)) else {
            return
        }
        
        let fetchResult = changes.fetchResultAfterChanges
        var newPhotos: [UIImage] = []
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        fetchResult.enumerateObjects { (asset, index, stop) in
            let targetSize = CGSize(width: 200, height: 200)
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                if let image = image {
                    newPhotos.append(image)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.recentPhotos = newPhotos
        }
    }
}
    


