//
//  FaceDetectionOverlayView.swift
//  SnapGroup
//
//  Created by Ayatullah Ma'arif on 25/06/24.
//

import SwiftUI
import Vision


struct FaceDetectionOverlayView: View {
    let faceObservation: VNFaceObservation
    let screenSize: CGSize
    var path: [CGRect]
    var watchConnector = WatchConnector.wc
    
    var body: some View {

        let boundingBox = faceObservation.boundingBox
        let size = CGSize(width: boundingBox.width * screenSize.width, height: boundingBox.height * screenSize.height)
        let origin = CGPoint(x: boundingBox.minX * screenSize.width, y: (1 - boundingBox.minY - boundingBox.height) * screenSize.height)
        let faceRect = CGRect(origin: origin, size: size)
        
        let isIntersecting = path.contains { rect in
            rect.contains(faceRect)
        }
        
        watchConnector.startConditionCheckTimer()
        
        if isIntersecting{
            DispatchQueue.main.async {
                self.watchConnector.shouldAlert = false
            }
        }
        
        if !isIntersecting{
            DispatchQueue.main.async {
                self.watchConnector.shouldAlert = true
            }
        }
        
        return Rectangle()
            .stroke(isIntersecting ? Color.green : Color.red, lineWidth: 2)
            .frame(width: size.width, height: size.height)
            .position(x: faceRect.midX, y: faceRect.midY)
    }
}
