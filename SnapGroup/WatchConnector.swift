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
    var conditionTimer: Timer?
    var shouldAlert: Bool = false {
        didSet {
            sendConditionToWatch()
        }
    }
    
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
    
    func sendConditionToWatch() {
        let message = ["shouldAlert": shouldAlert]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message to watch: \(error.localizedDescription)")
        }
    }
    
    func startConditionCheckTimer() {
        stopConditionCheckTimer()
        conditionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.sendConditionToWatch()
        }
    }
    
    func stopConditionCheckTimer() {
        conditionTimer?.invalidate()
        conditionTimer = nil
    }
    
}
