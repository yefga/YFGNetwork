//
//  YFGRequestInterceptor.swift
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

/// A protocol that defines methods for intercepting and adapting a `URLRequest` before it is sent.
///
/// This is the perfect place to inject authentication tokens, add signed headers, or perform any
/// other request modification that needs to happen dynamically and consistently across multiple endpoints.
/// Conforming to this protocol allows for custom interception logic to be injected into the network service,
/// promoting testability and separation of concerns.
@available(iOS 13.0, macOS 10.15, *)
public protocol YFGRequestInterceptor {
    
    /**
     A default interceptor that adds a common set of headers to a URL request.
     
     This method is called before a request is sent. It's an ideal place
     to inject authentication tokens, set `Content-Type` headers, or add any other
     required metadata to the outgoing request.
     
     ### Usage Example
     
     The following example demonstrates how to create an instance of the interceptor
     and use it to adapt a request.
     
     ```swift
     public class DefaultRequestInterceptor: YFGRequestInterceptor {
         
         // Example: A static token. In a real app, this would be retrieved securely from a keychain or auth service.
         private let authToken = "Bearer YOUR_SUPER_SECRET_AUTH_TOKEN"
         
         public init() {}
         
         public func adapt(_ request: URLRequest) async throws -> URLRequest {
             var mutableRequest = request
             
             // Add common headers that should be present on all or most requests.
             mutableRequest.setValue(YFGConstant.applicationJSON, forHTTPHeaderField: "Accept")
             mutableRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
             
             return mutableRequest
         }
     }

     ```
     
     - Parameter request: The original `URLRequest` that will be modified.
     - Returns: A new `URLRequest` instance with the added headers.
     - Throws: An error if any part of the adaptation process fails.
     */
    func adapt(_ request: URLRequest) async throws -> URLRequest
    
}


public class DefaultRequestInterceptor: YFGRequestInterceptor {
     
    public init() {}

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        
        // Add common headers that should be present on all or most requests.
        mutableRequest.setValue(YFGConstant.applicationJSON, forHTTPHeaderField: "Accept")
        
        return mutableRequest
    }
}
