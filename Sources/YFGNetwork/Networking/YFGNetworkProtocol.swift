//
//  YFGNetworkProtocol.swift
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

/// Defines the contract for a network service, making it easy to mock for testing.
@available(iOS 13.0, macOS 10.15, *)
public protocol YFGNetworkProtocol {
    /// Performs a network request and decodes the response
    func request<T: Decodable>(_ endpoint: YFGEndpoint) async throws -> T
    
    /// Downloads a file to the specified destination
    func download(_ endpoint: YFGEndpoint, to destination: URL) async throws -> URL
    
    /// Uploads data and decodes the response
    func upload<T: Decodable>(_ endpoint: YFGEndpoint, from data: Data) async throws -> T
    
    /// Performs a network request and returns raw data
    func data(_ endpoint: YFGEndpoint) async throws -> Data
    
}
