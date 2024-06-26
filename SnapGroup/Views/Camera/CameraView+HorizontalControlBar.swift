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
        VStack {
            HStack {
                flashToggleButton
                Spacer()
                timerButton
            }
            .padding(.top, 9)
            .padding(.bottom, 15)
            .padding(.horizontal, 20)
            HStack {
                Spacer()
                    .frame(width: controlButtonWidth)
                Spacer()
                if(VM.isCountingDown == true) {
                    cancelButton
                } else {
                    photoCaptureButton
                }
                Spacer()
                Spacer()
                    .frame(width: controlButtonWidth)
            }
        }
        .frame(height: 168.75)
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
