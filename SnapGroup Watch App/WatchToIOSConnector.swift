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
    
    var hapticTimer: Timer?
    var shouldContinueHaptic: Bool = false
    
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
        
        if let shouldAlert = message["shouldAlert"] as? Bool {
            if shouldAlert {
                startHapticTimer()
            } else {
                stopHapticTimer()
            }
        }
    }
    
    func startHapticTimer() {
        stopHapticTimer()  // Ensure any existing timer is invalidated
        triggerHapticFeedback()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.triggerHapticFeedback()
        }
    }

    func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    func triggerHapticFeedback() {
        WKInterfaceDevice.current().play(.notification)
    }





}
