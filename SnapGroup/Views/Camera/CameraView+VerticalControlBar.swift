//
//  CameraView+VerticalControlBar.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension CameraView {
    @ViewBuilder var verticalControlBar: some View {
        if (VM.hasPhoto) {
            verticalControlBarPostPhoto
        } else {
            verticalControlBarPrePhoto
        }
    }
    
    var verticalControlBarPrePhoto: some View {
        HStack {
            VStack {
                timerButton
                Spacer()
                flashToggleButton
            }
            .padding(.vertical, 20)
            VStack {
                Spacer()
                    .frame(height: controlButtonWidth)
                Spacer()
                photoCaptureButton
                Spacer()
                cancelButton
                    .frame(height: controlButtonWidth)
            }
        }
    }
    
    var verticalControlBarPostPhoto: some View {
        VStack {
            usePhotoButton
                .frame(height: controlButtonWidth)
            Spacer()
            retakeButton
                .frame(height: controlButtonWidth)
        }
    }
}

#Preview {
    CameraView()
}
