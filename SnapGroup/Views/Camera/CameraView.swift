//
//  CameraView.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//
import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @Environment(\.verticalSizeClass) var vertiSizeClass
    @Environment(\.dismiss) var dismiss
    
    @StateObject var VM = CameraViewModel()
    @StateObject private var photoLibraryViewModel = PhotoLibraryViewModel()
    
    var template: Template?
    
    @State var openTimer = false
    @State var showFullImage = false
    @State var focusPoint = CGPoint.zero
    @State var showFocusIndicator = false
    @State var countdown: Int? = nil
    @State var imageData: Data?
    @State var showRecentImage = false
    @State var selectedPhotoIndex = 0
    
    let controlButtonWidth: CGFloat = 120
    let controlFrameHeight: CGFloat = 180
    
    var isLandscape: Bool { vertiSizeClass == .compact }
    
    @State internal var isPhotoCaptureButtonDisabled = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                topControlBar
                
                HStack {
                    ZStack {
                        // CameraPreview
                        CameraPreview(cameraVM: VM, focusPoint: $focusPoint, showFocusIndicator: $showFocusIndicator)
                            .aspectRatio(3.0 / 4.0, contentMode: .fit)
                            .overlay(
                                GeometryReader { geo in
                                    ZStack {
                                        if template != nil {
                                            
                                            ForEach(VM.detectedFaces, id: \.self) { face in
                                                FaceDetectionOverlayView(faceObservation: face, screenSize: geo.size, path: template!.pathLogic)
                                            }
                                            
                                            SillhouteView(template: template!, cameraVM: VM)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                }
                            )
                    }
                    
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
        .sheet(isPresented: $showRecentImage) {
            PhotoDetailView(selectedPhotoIndex: $selectedPhotoIndex, photos: photoLibraryViewModel.recentPhotos)
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
                if let image = UIImage(data: data) {
                    photoLibraryViewModel.recentPhotos.append(image)
                }
            }
        }
        .navigationBarBackButtonHidden(true)

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
            showRecentImage.toggle()
        }) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 5)
        }
    }
}

struct PhotoDetailView: View {
    @Binding var selectedPhotoIndex: Int
    var photos: [UIImage]
    
    var body: some View {
        TabView(selection: $selectedPhotoIndex) {
            ForEach(photos.indices, id: \.self) { index in
                Image(uiImage: photos[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    CameraView(template: TemplateData().groupOf3[0])
}
