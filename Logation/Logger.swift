//
//  Logger.swift
//  Logation
//
//  Created by Subedi, Rikesh on 09/03/21.
//

import Foundation
import CoreLocation

protocol ILocationLogger {
    func log(lat: Double, long: Double, accuracy: LocationAccuracy?, time: Int64, ext: String, callback:  ((Any) -> Void)?)
}


public enum LocationAccuracy {
    case low
    case medium
    case high
}

public class Logger {
    public var accuracyLevel: LocationAccuracy
    private var url: String
    public init(url: String, accuracyLevel: LocationAccuracy  = CLLocationManager.locationServicesEnabled() ? .high : .low) {
        self.url = url
        self.accuracyLevel = accuracyLevel
    }
}

struct LogEntry {
    var lat: Double
    var long: Double
    var time: Int64
    var extras: String
}

extension LogEntry {
    func convertToPayload(level: LocationAccuracy) -> [String: Any] {
        var payload = [String: Any]()
        switch level {
        case .low:
            payload["lat"] = 0
            payload["long"] = 0
        default:
            payload["lat"] = self.lat
            payload["long"] = self.long
        }
        payload["time"] = self.time
        payload["extras"] = self.extras
        return payload
    }
}


extension Logger: ILocationLogger {
    public func log(lat: Double, long: Double, accuracy: LocationAccuracy? = nil,time: Int64 = Int64(Date().timeIntervalSince1970),  ext: String = "", callback:  ((Any) -> Void)? = nil) {
        let logEntry = LogEntry(lat: lat, long: long, time: time, extras: ext)
        let payload = logEntry.convertToPayload(level: accuracy ?? self.accuracyLevel)
        DispatchQueue.global().async {
            self.submit(payload: payload, callback: callback)
        }
    }

    private func submit(payload: [String: Any], callback:  ((Any) -> Void)?){
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
        }
    }
}
