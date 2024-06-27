//
//  WatchToIOSConnector.swift
//  SnapGroup Watch App
//
//  Created by Faisal Alfa on 21/06/24.
//

import Foundation
import WatchConnectivity
import SwiftUI


class WatchToIOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    @Published var receivedImage: UIImage?

    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sendMacroToiOS() {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let imageData = message["imageData"] as? Data {
            if let uiImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.receivedImage = uiImage
                }
            }
        }
    }
    
}
