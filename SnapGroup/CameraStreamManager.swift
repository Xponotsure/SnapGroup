//
//  CameraStreamManager.swift
//  SnapGroup
//
//  Created by Faisal Alfa on 22/06/24.
//

import AVFoundation
import WatchConnectivity
import UIKit

class CameraStreamManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    
    func startStreaming() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Add video input
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!)
        if captureSession.canAddInput(videoDeviceInput!) {
            captureSession.addInput(videoDeviceInput!)
        }
        
        // Add video output
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process sample buffer and send to watchOS
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                sendImageToWatch(image: uiImage)
            }
        }
    }
    
    func sendImageToWatch(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        if WCSession.default.isReachable {
            WCSession.default.sendMessageData(imageData, replyHandler: nil, errorHandler: nil)
        }
    }
}
