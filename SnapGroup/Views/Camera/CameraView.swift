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
    
    @State var imageData: Data?
    //    @State var showCamera: Bool?
    
    @State var openTimer = false
    
    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusIndicator: Bool = false
    @State private var countdown: Int? = nil
    
    let controlButtonWidth: CGFloat = 120
    let controlFrameHeight: CGFloat = 180
    
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
            
            if let countdown = countdown {
                Text("\(countdown)")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            VM.onCountdownUpdate = { value in
                withAnimation {
                    self.countdown = value
                }
            }
        }
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: $VM, frame: geo.frame (in: .global), focusPoint: $focusPoint, showFocusIndicator: $showFocusIndicator)
                .onAppear() {
                    VM.requestAccessAndSetup()
                }
                .aspectRatio(3.0/4.0,contentMode: .fit)
        }
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
    CameraView()
}
