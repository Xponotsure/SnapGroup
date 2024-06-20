//
//  CameraView+Buttons.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension CameraView {
    var usePhotoButton: some View {
        ControlButtonView(label: "Use Photo") {
            imageData = VM.photoData
            showCamera = false
        }
    }
    
    var retakeButton: some View {
        ControlButtonView(label: "Retake") {
            VM.retakePhoto()
        }
    }
    
    var cancelButton: some View {
        ControlButtonView(label: "Cancel") {
            showCamera = false
        }
    }
    
    var photoCaptureButton: some View {
        Button {
            VM.takePhoto()
        } label: {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 65)
                Circle()
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 75)
            }
        }
    }
    
    var flashToggleButton: some View {
        Button(action: {
            VM.toggleFlash()
        }) {
            Image(systemName: VM.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    CameraView (imageData: .constant(nil), showCamera: .constant(true))
}
