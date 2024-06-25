//
//  CameraView+HorizontalControlBar.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI
extension CameraView {
    @ViewBuilder var horizontalControlBar: some View {
        VStack {
            HStack {
                flashToggleButton
                Spacer()
                timerButton
            }
            .padding(.horizontal, 20)
            HStack {
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    thumbnailPreview(image: image)
                        .padding(.leading, 20)
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.leading, 20)
                }
                Spacer()
                photoCaptureButton
                Spacer()
                switchCameraButton
                    .padding(.trailing, 20)
                // cancelButton.frame(width: controlButtonWidth)
                
            }
        }
    }
}

#Preview {
    CameraView ()
}
