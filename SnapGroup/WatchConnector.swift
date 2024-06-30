//
//  WatchConnector.swift
//  SnapGroup
//
//  Created by Faisal Alfa on 21/06/24.
//

import Foundation
import WatchConnectivity
import Combine
import UIKit

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    static let wc = WatchConnector()

    var session: WCSession?
    var conditionTimer: Timer?
    
    @Published var shouldAlert: Bool = false {
        didSet {
            sendConditionToWatch()
        }
    }
    
    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
        

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
    
    // Generic method to send messages to the watch
    func send(message: [String: Any]) {
//        if ((session?.isReachable) != nil) {
            session!.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
//            }
        }
    }
    
    // Method to send image data to the watch
    func sendImageToWatch(_ imageData: Data) {
        send(message: ["imageData": imageData])
    }
    
    func sendConditionToWatch() {
        send(message: ["shouldAlert": shouldAlert])
    }
    
    func startConditionCheckTimer() {
        stopConditionCheckTimer()
        conditionTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.sendConditionToWatch()
        }
    }
    
    func stopConditionCheckTimer() {
        conditionTimer?.invalidate()
        conditionTimer = nil
    }
    
    func sendTemplate(_ template: Template){
        
        guard let img = UIImage(named: template.silhouetteImage) else { return }
        let imgData = img.pngData()
        send(message: ["silhouetteImage": imgData!])
        
        let orientation: String = template.orientation.rawValue
        
        send(message: ["orientation": orientation])
       
    }
}
