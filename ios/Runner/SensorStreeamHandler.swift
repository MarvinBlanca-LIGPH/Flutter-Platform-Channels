//
//  SensorStreeamHandler.swift
//  Runner
//
//  Created by Mark Marvin Blanca on 6/25/21.
//

import Foundation
import CoreMotion

class SensorStreamHandler: NSObject, FlutterStreamHandler {
    let cmAltimeter = CMAltimeter()
    let queue = OperationQueue()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            cmAltimeter.startRelativeAltitudeUpdates(to: queue) { (data, error) in
                if data != nil {
                    let pressure = data?.pressure.doubleValue ?? 0.0
                    events(pressure * 10.0)
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        cmAltimeter.stopRelativeAltitudeUpdates()
        return nil
    }
    
    
}
