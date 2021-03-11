//
//  Logger.swift
//  Logation
//
//  Created by Subedi, Rikesh on 09/03/21.
//

import Foundation
import CoreLocation

protocol ILocationLogger {
    func log(lat: Double, long: Double, accuracy: Double, time: Int64, ext: String, callback:  ((Any?) -> Void)?)
}

public class EQLogger {
    private var url: String
    private var loggerManager: LoggerManager
    public init(url: String, loggerManager: LoggerManager = LoggerManager(logger: NetworkLogger())) {
        self.url = url
        self.loggerManager = loggerManager
    }
}

struct LogEntry {
    var lat: Double
    var long: Double
    var time: Int64
    var extras: String
    var accuracy: CLLocationAccuracy
}

extension LogEntry {
    var payload : [String: Any] {
        var payload = [String: Any]()
        if(accuracy >= kCLLocationAccuracyReduced) {
            payload["lat"] = Double(0.0)
            payload["long"] = Double(0.0)
        } else {
            payload["lat"] = self.lat
            payload["long"] = self.long
        }
        payload["time"] = self.time
        payload["extras"] = self.extras
        return payload
    }
}


extension EQLogger: ILocationLogger {
    public func log(lat: Double, long: Double, accuracy: CLLocationAccuracy,time: Int64 = Int64(Date().timeIntervalSince1970),  ext: String = "", callback:  ((Any?) -> Void)? = nil) {
        let logEntry = LogEntry(lat: lat, long: long, time: time, extras: ext, accuracy: accuracy)
        DispatchQueue.global().async {
            self.submit(payload: logEntry.payload, callback: callback)
        }
    }

    public func log(callback:((Any?) -> Void)? = nil) {
        if !CLLocationManager.locationServicesEnabled() {
            self.log(lat: 0, long: 0, accuracy: kCLLocationAccuracyReduced, callback: callback)
        } else if let lastUpdatedLocation = LocationUpdater.shared.lastLocation, lastUpdatedLocation.timestamp.timeIntervalSinceNow < 2 {
            self.log(lat: lastUpdatedLocation.coordinate.latitude, long: lastUpdatedLocation.coordinate.longitude, accuracy: lastUpdatedLocation.horizontalAccuracy, callback: callback)
        } else {
            LocationUpdater.shared.startUpdating { [self] (location) in
                self.log(lat: location.coordinate.latitude, long: location.coordinate.longitude, accuracy: location.horizontalAccuracy, callback: callback)
            }
        }
    }

    private func submit(payload: [String: Any], callback:  ((Any?) -> Void)?){
        self.loggerManager.postData(url: self.url, payload: payload, callback: callback)
    }
}
