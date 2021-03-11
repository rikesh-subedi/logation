//
//  NetworkManager.swift
//  Logation
//
//  Created by Subedi, Rikesh on 11/03/21.
//

import Foundation

public protocol RemoteLogger {
    func submitData(url: String, payload: [String: Any], callback: ((Any?)->Void)?)
}

public class NetworkLogger: RemoteLogger {
    public init() {

    }
    public func submitData(url: String, payload: [String : Any], callback: ((Any?) -> Void)?) {
        if let url = URL(string: url) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let data = try? JSONSerialization.data(withJSONObject: payload, options: [])
            urlRequest.httpBody = data
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async {
                    if let _ = error {
                        callback?(nil)
                    } else {
                        callback?(payload)
                    }
                }
            }
            task.resume()
        } else {
            print("INVALID URL")
            callback?(nil)
        }
    }
}

public class LoggerManager {
    var logger: RemoteLogger
    public init(logger: RemoteLogger) {
        self.logger = logger
    }

    func postData(url: String, payload: [String: Any], callback: ((Any?)->Void)?) {
        logger.submitData(url: url, payload: payload, callback: callback)
    }
}
