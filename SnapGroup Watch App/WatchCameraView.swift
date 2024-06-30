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
                ZStack{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .rotationEffect(connector.orientation == "potrait" ? .degrees(90) : .degrees(0))
                        .overlay(
                            GeometryReader { geo in
                                if let sillhoutteImage = connector.sillhoutteImage {
                                    ZStack{
                                        Image(uiImage: sillhoutteImage)
                                            .resizable()
                                            .scaledToFill()
                                            .rotationEffect(connector.orientation == "potrait" ? .degrees(0) : .degrees(90))
                                        
                                    }
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    
                                }
                                
                            }
                            
                        )
                    
                }
            } else {
                Text("Waiting for image...")
            }
        }
        .ignoresSafeArea()
        
    }
}

#Preview {
    WatchCameraView(connector: WatchToIOSConnector())
}
