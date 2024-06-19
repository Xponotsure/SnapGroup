//
//  View+.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension View {
    func fullScreenCamera(isPresented: Binding<Bool>, imageData: Binding<Data?>) -> some View {
    self
        .fullScreenCover(isPresented: isPresented, content: {
            CameraView(imageData: imageData, showCamera: isPresented)
        })
    }
}
