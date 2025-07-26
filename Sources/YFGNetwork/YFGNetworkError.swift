//
//  YFGNetworkError.swift
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
// YFGNetworkError.swift - Enhanced error cases
public enum YFGNetworkError: LocalizedError {
    case noConnection
    case invalidURL
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case requestTimeout
    case tooManyRequests
    case internalServerError
    case serviceUnavailable
    case badResponse(statusCode: Int)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case requestFailed(Error)
    case invalidContentType
    case certificatePinningFailed
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .requestTimeout:
            return "Request timed out"
        case .tooManyRequests:
            return "Too many requests"
        case .internalServerError:
            return "Internal server error"
        case .serviceUnavailable:
            return "Service unavailable"
        case .badResponse(let statusCode):
            return "Bad response with status code: \(statusCode)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidContentType:
            return "Invalid content type"
        case .certificatePinningFailed:
            return "Certificate pinning validation failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}