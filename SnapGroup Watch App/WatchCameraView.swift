//
//  WatchCameraView.swift
//  SnapGroup Watch App
//
//  Created by Ayatullah Ma'arif on 27/06/24.
//

import SwiftUI

struct WatchCameraView: View {
    @ObservedObject var connector: WatchToIOSConnector

    var body: some View {
        VStack {
            if let image = connector.receivedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(90))
            } else {
                Text("Waiting for image...")
            }
        }
        .ignoresSafeArea(.all)

    }
}

#Preview {
    WatchCameraView(connector: WatchToIOSConnector())
}
