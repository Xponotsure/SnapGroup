//
//  ContentView.swift
//  SnapGroup Watch App
//
//  Created by Ayatullah Ma'arif on 19/06/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var image: UIImage? = nil
    
    var body: some View {
        VStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Waiting for stream...")
            }
        }
        .onAppear {
            WatchSessionManager.shared.receiveImage = { uiImage in
                self.image = uiImage
            }
        }
    }
}

class WatchSessionManager: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
    }
    
    static let shared = WatchSessionManager()
    var receiveImage: ((UIImage) -> Void)?
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let image = UIImage(data: messageData) {
            receiveImage?(image)
        }
    }
}
