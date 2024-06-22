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
    
    @StateObject private var VM = CameraViewModel()
    
    @State private var openTimer = false
    @State private var showFullImage = false
    @State private var focusPoint = CGPoint.zero
    @State private var showFocusIndicator = false
    @State private var countdown: Int? = nil
    @State private var imageData: Data?

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
        .sheet(isPresented: $showFullImage) {
            if let imageData = imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            VM.onCountdownUpdate = { value in
                withAnimation {
                    self.countdown = value
                }
            }
        }
        .onReceive(VM.$photoCaptureState) { state in
            if case .finished(let data) = state {
                self.imageData = data
            }
        }
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: VM, frame: geo.frame(in: .global), focusPoint: $focusPoint, showFocusIndicator: $showFocusIndicator)
                .onAppear {
                    VM.requestAccessAndSetup()
                }
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
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
    
    private func thumbnailPreview(image: UIImage) -> some View {
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

extension CameraView {
    var cancelButton: some View {
        ControlButtonView(label: "Cancel") {}
    }
    
    var photoCaptureButton: some View {
        Button {
            VM.startTimer()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 65)
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 75)
            }
        }
    }
    
    var flashToggleButton: some View {
        Button(action: {
            VM.toggleFlash()
        }) {
            Image(systemName: VM.isFlashOn ? "bolt.circle" : "bolt.slash.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 29, height: 29)
                .foregroundColor(.white)
                .frame(width: 39, height: 39)
                .padding(5)
                .background(Color(red: 50/255, green: 50/255, blue: 50/255))
                .clipShape(Circle())
        }
    }
    
    var timerButton: some View {
        Button(action: {
            openTimer.toggle()
        }) {
            HStack(spacing: -40) {
                Image(systemName: "timer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 29, height: 29)
                    .foregroundColor(.white)
                    .frame(width: 39, height: 39)
                    .padding(5)
                    .background(Color(red: 50/255, green: 50/255, blue: 50/255))
                    .clipShape(Circle())
                    .zIndex(1.0)
                
                if openTimer {
                    HStack {
                        Button(action: { VM.timeSet = 0; openTimer.toggle() }) {
                            Text("Off")
                        }
                        .padding(10)
                        Button(action: { VM.timeSet = 3; openTimer.toggle() }) {
                            Text("3s")
                        }
                        .padding(10)
                        Button(action: { VM.timeSet = 10; openTimer.toggle() }) {
                            Text("10s")
                        }
                        .padding(10)
                    }
                    .frame(height: 39)
                    .padding(5)
                    .padding(.leading, 30)
                    .foregroundColor(.white)
                    .background(Color(red: 81/255, green: 81/255, blue: 81/255))
                    .cornerRadius(100)
                }
            }
        }
    }
}

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
                        .padding(.leading, 30)
                }
                Spacer()
                photoCaptureButton
                Spacer()
            }
        }
    }
    
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
                        .padding(.bottom, 20)
                }
                Spacer().frame(height: controlButtonWidth)
                Spacer()
                photoCaptureButton
                Spacer()
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraVM: CameraViewModel
    let frame: CGRect
    
    @Binding var focusPoint: CGPoint
    @Binding var showFocusIndicator: Bool
    
    class Coordinator: NSObject {
        var parent: CameraPreview

        init(parent: CameraPreview) {
            self.parent = parent
        }

        @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            let frameSize = gesture.view?.frame.size ?? CGSize.zero
            let focusPoint = CGPoint(x: location.y / frameSize.height, y: 1.0 - location.x / frameSize.width)

            parent.focusPoint = location
            parent.showFocusIndicator = true
            parent.cameraVM.focus(at: focusPoint)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: frame)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
        cameraVM.preview = AVCaptureVideoPreviewLayer(session: cameraVM.session)
        cameraVM.preview.frame = frame
        cameraVM.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraVM.preview)
        
        let previewWidth = frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let previewWidth = frame.width
        let previewHeight = previewWidth * 4 / 3
        cameraVM.preview.frame = CGRect(x: 0, y: (frame.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
        cameraVM.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
    }
}

struct ControlButtonView: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .tint(.white)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    CameraView()
}
