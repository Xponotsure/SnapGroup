//
//  CameraView.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//
import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.verticalSizeClass) var vertiSizeClass
    
    @StateObject  var VM = CameraViewModel()
    
    @State  var openTimer = false
    @State  var showFullImage = false
    @State  var focusPoint = CGPoint.zero
    @State  var showFocusIndicator = false
    @State  var countdown: Int? = nil
    @State var imageData: Data?

    let controlButtonWidth: CGFloat = 120
    let controlFrameHeight: CGFloat = 180
    
    var isLandscape: Bool { vertiSizeClass == .compact }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    cameraPreview
                    if isLandscape {
                        verticalControlBar.frame(width: controlFrameHeight)
                    }
                }
                if !isLandscape {
                    horizontalControlBar.frame(height: controlFrameHeight)
                }
            }
            
            if showFocusIndicator {
                focusIndicator.position(focusPoint)
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
        
        .sheet(isPresented: $showFullImage) {
            if let imageData = imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }

        .onReceive(VM.$photoCaptureState) { state in
            if case .finished(let data) = state {
                self.imageData = data
            }
        }
    }
    
     var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: VM, frame: geo.frame(in: .global), focusPoint: $focusPoint, showFocusIndicator: $showFocusIndicator)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
        }
    }
    
     var focusIndicator: some View {
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
    
     func thumbnailPreview(image: UIImage) -> some View {
        Button(action: {
            showFullImage.toggle()
        }) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 5)
        }
    }
}






#Preview {
    CameraView()
}
