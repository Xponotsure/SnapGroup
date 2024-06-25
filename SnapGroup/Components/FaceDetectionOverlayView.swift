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
    
    var body: some View {
        let boundingBox = faceObservation.boundingBox
        let size = CGSize(width: boundingBox.width * screenSize.width, height: boundingBox.height * screenSize.height)
        let origin = CGPoint(x: boundingBox.minX * screenSize.width, y: (1 - boundingBox.minY - boundingBox.height) * screenSize.height)
        let rect = CGRect(origin: origin, size: size)
        
        return Rectangle()
            .path(in: rect)
            .stroke(Color.red, lineWidth: 2)
            .frame(width: screenSize.width, height: screenSize.height, alignment: .topLeading)
    }
}
