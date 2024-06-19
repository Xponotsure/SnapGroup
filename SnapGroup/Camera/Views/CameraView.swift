//
//  CameraView.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.verticalSizeClass) var vertiSizeClass
    
    @State internal var VM = CameraViewModel()
    
    @Binding var imageData: Data?
    @Binding var showCamera: Bool
    
    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusIndicator: Bool = false
    
    let controlButtonWidth: CGFloat = 120
    let controlFrameHeight: CGFloat = 90
    
    var isLandscape: Bool {vertiSizeClass == .compact}
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                HStack {
                    cameraPreview
                    
                    if isLandscape {
                        verticalControlBar
                            .frame(width: controlFrameHeight)
                    }
                }
                if !isLandscape {
                    horizontalControlBar
                        .frame(height: controlFrameHeight)
                }
            }
            
            if showFocusIndicator {
                focusIndicator
                    .position(focusPoint)
            }
        }
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: $VM, frame: geo.frame (in: .global), focusPoint: $focusPoint, showFocusIndicator: $showFocusIndicator)
                .onAppear() {
                    VM.requestAccessAndSetup()
                }
        }
        .ignoresSafeArea()
    }
    
    private var focusIndicator: some View {
        Rectangle()
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: 80, height: 80)
            .opacity(showFocusIndicator ? 0.8 : 0)
            .animation(.easeInOut(duration: 0.5), value: showFocusIndicator)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showFocusIndicator = false
                }
            }
    }
}

#Preview {
    CameraView (imageData: .constant(nil), showCamera: .constant(true))
}
