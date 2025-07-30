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
    case badResponse(statusCode: Int?)
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
            return "Bad response with status code: \(statusCode ?? -1)"
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
    
    static func mapStatusCodeToNetworkError(_ statusCode: Int) -> Self {
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 408:
            return .requestTimeout
        case 429:
            return .tooManyRequests
        case 500:
            return .internalServerError
        case 503:
            return .serviceUnavailable
        default:
            return .badResponse(statusCode: statusCode)
        }
    }
}

public typealias YFGDecodeSendable = Decodable & Sendable

/// Generic error model that can parse server error responses
public struct YFGErrorModel: Error {
    public var errorCode: Int?
    public var errorMessage: YFGNetworkError?
    public var errorData: Data?
    
    public init(
        errorCode: Int? = nil,
        errorMessage: YFGNetworkError? = nil,
        errorData: Data? = nil
    ) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.errorData = errorData
    }
    
    public func mappedToModel<T: Decodable>(_ type: T.Type) throws -> T {
        if let data = errorData {
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data available to decode"))
        }
    }
    
    public var errorDescription: String? {
        return errorMessage?.errorDescription ?? "Unknown error occurred"
    }
}
