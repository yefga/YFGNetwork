//
//  YFGNetworkMonitor.swift
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
import Network

@available(iOS 13.0, macOS 10.15, *)
public actor YFGNetworkMonitor {
    
    // MARK: - Singleton
    public static let shared = YFGNetworkMonitor()
    
    // MARK: - Properties
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.YFGnetwork.monitor", qos: .utility)
    
    private var _isConnected: Bool = true
    private var _currentPath: NWPath?
    
    // MARK: - Handlers
    private var connectionHandlers: [UUID: (Bool) -> Void] = [:]
    private var pathHandlers: [UUID: (NWPath) -> Void] = [:]
    
    // MARK: - Public Properties
    public var isConnected: Bool {
        _isConnected
    }
    
    public var currentPath: NWPath? {
        _currentPath
    }
    
    public var connectionType: ConnectionType {
        guard let path = _currentPath else { return .unknown }
        
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else if path.status == .satisfied {
            return .other
        } else {
            return .none
        }
    }
    
    public var isExpensive: Bool {
        _currentPath?.isExpensive ?? false
    }
    
    public var isConstrained: Bool {
        _currentPath?.isConstrained ?? false
    }
    
    // MARK: - Initialization
    private init() {
        self.monitor = NWPathMonitor()
        Task {
            await startMonitoring()
        }
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Public Handler API
    
    /// Registers a connection status handler
    /// - Parameter handler: Closure receiving connection status (true = connected)
    /// - Returns: UUID to identify handler for removal
    public func addConnectionHandler(_ handler: @escaping (Bool) -> Void) -> UUID {
        let id = UUID()
        connectionHandlers[id] = handler
        
        // Immediately provide current state
        handler(_isConnected)
        
        return id
    }
    
    /// Registers a network path detail handler
    /// - Parameter handler: Closure receiving NWPath updates
    /// - Returns: UUID to identify handler for removal
    public func addPathHandler(_ handler: @escaping (NWPath) -> Void) -> UUID {
        let id = UUID()
        pathHandlers[id] = handler
        
        // Immediately provide current path if available
        if let path = _currentPath {
            handler(path)
        }
        
        return id
    }
    
    /// Removes a connection handler
    public func removeConnectionHandler(id: UUID) {
        connectionHandlers.removeValue(forKey: id)
    }
    
    /// Removes a path handler
    public func removePathHandler(id: UUID) {
        pathHandlers.removeValue(forKey: id)
    }
    
    /// Suspends execution until a network connection is available
    public func waitForConnection() async {
        if _isConnected { return }
        
        await withCheckedContinuation { continuation in
            let handlerID = addConnectionHandler { [weak self] isConnected in
                guard isConnected else { return }
                
                // Remove handler and resume continuation
                Task { [weak self] in
                    await self?.removeConnectionHandler(id: handlerID)
                    continuation.resume()
                }
            }
        }
    }
    
    /// Checks if a specific interface tYFGe is currently available
    public func isInterfaceAvailable(_ tYFGe: NWInterface.InterfaceType) -> Bool {
        _currentPath?.usesInterfaceType(tYFGe) ?? false
    }
    
    // MARK: - Private Monitoring Methods
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updatePath(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updatePath(_ path: NWPath) {
        let wasConnected = _isConnected
        _currentPath = path
        _isConnected = path.status == .satisfied
        
        // Notify all connection handlers if status changed
        if wasConnected != _isConnected {
            for handler in connectionHandlers.values {
                handler(_isConnected)
            }
        }
        
        // Always notify path handlers of new path
        for handler in pathHandlers.values {
            handler(path)
        }
    }
}

// MARK: - Supporting TYFGes (unchanged)
@available(iOS 13.0, macOS 10.15, *)
public enum ConnectionType: String, CaseIterable {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case other = "Other"
    case none = "None"
    case unknown = "Unknown"
}