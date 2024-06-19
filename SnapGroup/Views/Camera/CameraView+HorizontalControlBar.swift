//
//  CameraView+HorizontalControlBar.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension CameraView {
    @ViewBuilder var horizontalControlBar: some View {
        if (VM.hasPhoto) {
            horizontalControlBarPostPhoto
        } else {
            horizontalControlBarPrePhoto
        }
    }
    
    var horizontalControlBarPrePhoto: some View {
        HStack {
            cancelButton
                .frame(width: controlButtonWidth)
            Spacer()
            photoCaptureButton
            Spacer()
            flashToggleButton
                .frame(width: controlButtonWidth)
        }
    }
    
    var horizontalControlBarPostPhoto: some View {
        HStack {
            retakeButton
                .frame(width: controlButtonWidth)
            Spacer()
            usePhotoButton
                .frame(width: controlButtonWidth)
        }
    }
}

#Preview {
    CameraView ()
}
