//
//  YFGEndpoint.swift
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
/// A protocol for defining the properties of a specific API endpoint.
/// An enum is the recommended way to conform to this protocol, providing type-safe API definitions.
public protocol YFGEndpoint {
    /// The path to be appended to the `baseURL` to form the full URL.
    var path: String { get }
    
    /// The HTTP method for the request.
    var method: YFGHTTPMethod { get }
    
    /// The headers to be added to the request.
    var headers: [String: String]? { get }
    
    /// The task defining the request's body or parameters.
    var task: YFGTask { get }
    
    /// The caching policy for the request. Defaults to `.useProtocolCachePolicy`.
    var cachePolicy: URLRequest.CachePolicy { get }

    /// The timeout interval for the request. Defaults to 60 seconds.
    var timeoutInterval: TimeInterval { get }
    
    /// The retry policy for the request. Defaults to no retries.
    var retryPolicy: YFGRetryPolicy { get }
    
    /// A boolean value to determine if the request should be adapted by the `YFGRequestInterceptor`.
    /// Defaults to `true`. Return `false` for endpoints that do not require interception (e.g., public routes).
    var needsInterceptor: Bool { get }
}
