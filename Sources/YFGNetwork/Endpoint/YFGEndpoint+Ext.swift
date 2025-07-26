//
//  YPEndpoint+Ext.swift
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

// MARK: - Default Implementations
public extension YFGEndpoint {
    /// Provides a default caching policy.
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    /// Provides a default retry policy of no retries.
    var retryPolicy: YFGRetryPolicy {
        return YFGRetryPolicy()
    }
    
    /// Default implementation for `needsInterceptor`. By default, all requests are intercepted.
    /// Override this property in your endpoint definition and return `false` for public endpoints.
    var needsInterceptor: Bool {
        return true
    }
}

// MARK: - Supporting Types

public struct EmptyResponse: Decodable {}
