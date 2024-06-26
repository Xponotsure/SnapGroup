//
//  CameraView+Buttons.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension CameraView {
    var cancelButton: some View {
        Button {
            VM.cancelCapturePhoto()
            
            isPhotoCaptureButtonDisabled = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isPhotoCaptureButtonDisabled = false
            }
        } label: {
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                Circle()
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 75)
            }
        }
    }
    
    var photoCaptureButton: some View {
        Button {
            VM.takePhoto()
        } label: {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 65)
                Circle()
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 75)
            }
        }
        .disabled(isPhotoCaptureButtonDisabled)
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
    
    var switchCameraButton: some View {
        Button(action: {
            VM.switchCamera()
        }) {
            Image(systemName: "camera.rotate")
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
                        Button(action: { VM.timeSet = 10; openTimer.toggle()  }) {
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


#Preview {
    CameraView()
}
