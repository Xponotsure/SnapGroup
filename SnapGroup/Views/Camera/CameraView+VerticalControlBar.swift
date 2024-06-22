//
//  CameraView+VerticalControlBar.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension CameraView {
    @ViewBuilder var verticalControlBar: some View {
        HStack {
            VStack {
                timerButton
                Spacer()
                flashToggleButton
            }
            .padding(.vertical, 20)
            VStack {
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    thumbnailPreview(image: image)
                        .padding(.top,20)
                }
                else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 25)
                }
                Spacer().frame(height:90)
                
                photoCaptureButton

                Spacer()
                switchCameraButton
                    .padding(.top,25)
                // cancelButton.frame(height: controlButtonWidth)
                Spacer()
            }
        }
    }
}

#Preview {
    CameraView()
}
