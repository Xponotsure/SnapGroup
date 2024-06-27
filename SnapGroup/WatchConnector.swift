//
//  WatchConnector.swift
//  SnapGroup
//
//  Created by Faisal Alfa on 21/06/24.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session inactivity
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle receiving a message from the watch
    }
    
    // Method to send image data to the watch
    func sendImageToWatch(_ imageData: Data) {
        if session.isReachable {
            session.sendMessage(["imageData": imageData], replyHandler: nil, errorHandler: nil)
        }
    }
}
