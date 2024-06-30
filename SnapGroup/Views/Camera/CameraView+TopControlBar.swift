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
        .padding(.vertical, 2)
        .padding(.horizontal, 5)

        .background(Color(red: 50/255, green: 50/255, blue: 50/255))
        .cornerRadius(100)
    }
    
    @ViewBuilder var topControlBar: some View {
        HStack{
            VStack {
                HStack {
                    if(VM.timeSet != 0) {
                        timerStatus
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: {
                showSettings = true
            }, label: {
                Image(systemName: "person.3.fill")
                    .resizable()
                    .scaledToFit()
//                    .font(.system(size: 24))
                    .frame(width: 16)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
            })
            
        }
        .frame(height: 77.25)
    }
}

#Preview {
    CameraView(template: TemplateData().groupOf3[0])
}
