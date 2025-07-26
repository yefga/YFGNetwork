//
//  YFGNetworkLogger.swift
//  YFGNetwork
//
//  Created by Yefga on 26/07/2025.
//
//  Copyright (c) 2025 Yefga Torra <yefga@naver.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// A protocol for logging network requests and responses.
///
/// Separating logging into its own component allows us to control the level of detail
/// and destination of logs without cluttering the core network service. For example, we could
/// implement a logger that sends data to a remote analytics service in a production build.
@available(iOS 13.0, macOS 10.15, *)
public protocol YFGLoggerProtocol {
    
    /// Logs an outgoing network request.
    /// - Parameter request: The `URLRequest` being sent.
    func log(request: URLRequest)
    
    /// Logs a received network response.
    /// - Parameters:
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - data: The `Data` from the response body.
    ///   - error: An optional `Error` if the request failed.
    ///   - endpoint: The `YFGEndpoint` that initiated the request, for context.
    func log(response: URLResponse?, data: Data?, error: Error?, for endpoint: YFGEndpoint)
}


/// A default logger that prints detailed network activity to the console using `NSLog`.
///
/// This implementation is designed for development and debugging. It provides a clean,
/// formatted output that makes it easy to inspect network traffic via Xcode or the device's Console app.
@available(iOS 13.0, macOS 10.15, *)
public class YFGLogger: YFGLoggerProtocol {
    
    public init() {}
    
    public func log(request: URLRequest) {
        let message = """
        ➡️ 🚀 [REQUEST] \(request.httpMethod ?? "N/A") \(request.url?.absoluteString ?? "N/A")
        """
        NSLog("%@", message)
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            NSLog("   [HEADERS] %@", "\(headers)")
        }
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            NSLog("   [BODY] %@", bodyString)
        }
    }
    
    public func log(response: URLResponse?, data: Data?, error: Error?, for endpoint: YFGEndpoint) {
        guard let httpResponse = response as? HTTPURLResponse else {
            if let err = error as? URLError {
                NSLog("⬅️ ❌ [ERROR] for \(endpoint.path): %@", err.localizedDescription)
            } else {
                NSLog("⬅️ ❌ [ERROR] for \(endpoint.path): %@", error?.localizedDescription ?? "Unknown error")
            }
            return
        }
        
        let statusCode = httpResponse.statusCode
        let statusIcon = (200...299).contains(statusCode) ? "✅" : "❌"
        
        NSLog("⬅️ \(statusIcon) [RESPONSE] \(statusCode) from \(httpResponse.url?.absoluteString ?? "N/A")")
        
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            // To avoid overly verbose logs, you might truncate large responses
            let logString = dataString.count > 1000 ? "\(dataString.prefix(1000))... (truncated)" : dataString
            NSLog("    [DATA] %@", logString)
        }
        
        if let error = error {
            NSLog("    [ERROR] %@", error.localizedDescription)
        }
    }
}
