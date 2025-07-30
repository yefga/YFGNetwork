//
//  YFGResponseValidator.swift
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

/// A protocol for validating a network response.
///
/// By abstracting validation logic, we can easily swap out different validation strategies.
/// For example, one validator might only accept 200-299 status codes, while another
/// might handle more complex scenarios involving custom response headers.
@available(iOS 13.0, macOS 10.15, *)
public protocol YFGResponseValidator {
    
    /// Validates the response and throws an appropriate `YFGNetworkError` if validation fails.
    ///
    /// - Parameters:
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - data: The raw `Data` received from the server.
    /// - Throws: A `YFGNetworkError` if the response is considered invalid.
    func validate(_ response: HTTPURLResponse?) throws
}


/// A default implementation of `YFGResponseValidator` that validates based on HTTP status codes.
///
/// This validator maps standard HTTP status code ranges to the `YFGNetworkError` enum,
/// providing clear, descriptive errors for common failure cases.
public class DefaultResponseValidator: YFGResponseValidator {
    
    public init() {}
    
    public func validate(_ response: HTTPURLResponse?) throws {
        switch response?.statusCode ?? 0 {
        case (200...299):
            // Success, no error thrown.
            return
        case 400:
            throw YFGNetworkError.badRequest
        case 401:
            throw YFGNetworkError.unauthorized
        case 403:
            throw YFGNetworkError.forbidden
        case 404:
            throw YFGNetworkError.notFound
        case 408:
            throw YFGNetworkError.requestTimeout
        case 429:
            throw YFGNetworkError.tooManyRequests
        case 500:
            throw YFGNetworkError.internalServerError
        case 503:
            throw YFGNetworkError.serviceUnavailable
        default:
            throw YFGNetworkError.badResponse(statusCode: response?.statusCode)
        }
    }
}
