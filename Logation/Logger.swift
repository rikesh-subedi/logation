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

public class Logger {
    private var url: String
    public init(url: String) {
        self.url = url
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
        if(accuracy == 0) {
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


extension Logger: ILocationLogger {
    public func log(lat: Double, long: Double, accuracy: CLLocationAccuracy,time: Int64 = Int64(Date().timeIntervalSince1970),  ext: String = "", callback:  ((Any?) -> Void)? = nil) {
        let logEntry = LogEntry(lat: lat, long: long, time: time, extras: ext, accuracy: accuracy)
        DispatchQueue.global().async {
            self.submit(payload: logEntry.payload, callback: callback)
        }
    }

    public func logLocation(callback:((Any?) -> Void)? = nil) {
        if !CLLocationManager.locationServicesEnabled() {
            self.log(lat: 0, long: 0, accuracy: 0, callback: callback)
        } else if let lastUpdatedLocation = LocationUpdater.shared.lastLocation, lastUpdatedLocation.timestamp.timeIntervalSinceNow < 2 {
            self.log(lat: lastUpdatedLocation.coordinate.latitude, long: lastUpdatedLocation.coordinate.longitude, accuracy: lastUpdatedLocation.horizontalAccuracy, callback: callback)
        } else {
            LocationUpdater.shared.startUpdating { [weak self] (location) in
                self?.log(lat: location.coordinate.latitude, long: location.coordinate.longitude, accuracy: location.horizontalAccuracy, callback: callback)
            }
        }
    }

    private func submit(payload: [String: Any], callback:  ((Any?) -> Void)?){
        if let url = URL(string: self.url) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let data = try? JSONSerialization.data(withJSONObject: payload, options: [])
            urlRequest.httpBody = data
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async {
                    callback?(payload)
                }
            }
            task.resume()
        } else {
            print("INVALID URL")
            callback?(nil)
        }
    }
}
