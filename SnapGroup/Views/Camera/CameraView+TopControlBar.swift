//
//  CameraView+HorizontalControlBar.swift
//  rotateCamera
//
//  Created by Channy Lim on 17/06/24.
//

import SwiftUI

extension CameraView {
    var timerStatus: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 14)
            Text("\(VM.timeSet)s")
                .font(.subheadline)
        }
        .frame(minWidth: 43, minHeight: 24)
        .foregroundColor(.white)
        .padding(5)
        .background(Color(red: 50/255, green: 50/255, blue: 50/255))
        .cornerRadius(100)
    }
    
    @ViewBuilder var topControlBar: some View {
        VStack {
            HStack {
                if(VM.timeSet != 0) {
                    timerStatus
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 77.25)
    }
}

#Preview {
    CameraView ()
}
