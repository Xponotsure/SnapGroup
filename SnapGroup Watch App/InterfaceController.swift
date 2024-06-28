//
//  InterfaceController.swift
//  SnapGroup Watch App
//
//  Created by Ayatullah Ma'arif on 27/06/24.
//

import WatchKit
import Foundation
import WatchConnectivity
import SwiftUI

class InterfaceController: WKHostingController<WatchCameraView> {
    var connector = WatchToIOSConnector()
    
    override var body: WatchCameraView {
        return WatchCameraView(connector: connector)
    }
    
    override func willActivate() {
        super.willActivate()
        connector.session.activate()
    }
    
    func sendAlertHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
}

//class InterfaceController: WKHostingController<WatchCameraView> {
//    var session: WCSession?
//
//    override var body: WatchCameraView {
//        return WatchCameraView()
//    }
//
//    override func willActivate() {
//        super.willActivate()
//
//        if WCSession.isSupported() {
//            session = WCSession.default
//            session?.delegate = self
//            session?.activate()
//        }
//    }
//}
//
//extension InterfaceController: WCSessionDelegate {
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        // Handle activation completion
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
//        if let imageData = message["imageData"] as? Data {
//            if let uiImage = UIImage(data: imageData) {
//                // Update the SwiftUI view with the received image
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: .receivedImageData, object: uiImage)
//                }
//            }
//        }
//    }
//}
