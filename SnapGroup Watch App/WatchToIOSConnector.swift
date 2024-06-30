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
    
    //template
    @Published var sillhoutteImage: UIImage?
    @Published var orientation: String?
    
    var hapticTimer: Timer?
    var shouldContinueHaptic: Bool = false
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("WC Session activation completed: \(activationState.rawValue)")
        if let error = error {
            print("WC Session activation failed: \(error.localizedDescription)")
        }
    }
    
    func sendMacroToiOS() {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            
            if let imageData = message["imageData"] as? Data {
                if let uiImage = UIImage(data: imageData) {
                    self.receivedImage = uiImage
                    
                }
            }
            
            if let shouldAlert = message["shouldAlert"] as? Bool {
                if shouldAlert {
                    self.startHapticTimer()
                } else {
                    self.stopHapticTimer()
                }
            }
            
            //templaate
            if let sillhoutteImageData = message["silhouetteImage"] as? Data{
                if let uiImage = UIImage(data: sillhoutteImageData) {
                    self.sillhoutteImage = uiImage
                    
                }
            }
            if let orientation = message["orientation"] as? String{
                    self.orientation = orientation
                print(self.orientation!)
                
            }

            
//            if let pathLogicData = message["pathLogic"] as? [[String: Any]] {
//                do {
//                    let data = try JSONSerialization.data(withJSONObject: pathLogicData, options: [])
//                    let decodedPathLogic = try JSONDecoder().decode([CGRect].self, from: data)
//                    self.pathLogic = decodedPathLogic
//                    
//                } catch {
//                    print("Error decoding pathLogic: \(error.localizedDescription)")
//                }
//            }
            
            
        }
    }
    
    
    
    func startHapticTimer() {
        stopHapticTimer()  // Ensure any existing timer is invalidated
        triggerHapticFeedback()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.triggerHapticFeedback()
        }
    }
    
    func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    func triggerHapticFeedback() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    
    
    
    
}
