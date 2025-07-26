//
//  URLRequest+Builder.swift
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

@available(iOS 13.0, macOS 10.15, *)
internal extension URLRequest {
    
    /// A static factory method to create a `URLRequest` from an endpoint definition.
    ///
    /// This builder encapsulates the logic for translating a high-level `YFGEndpoint`
    /// definition into a low-level `URLRequest` object. It handles URL construction,
    /// parameter encoding, and body serialization, throwing specific errors for each
    /// potential failure point.
    ///
    /// - Parameters:
    ///   - endpoint: The `YFGEndpoint` to be converted into a request.
    ///   - environment: The `YFGEnvironment` providing the base URL.
    ///   - jsonEncoder: A `JSONEncoder` to use for encoding request bodies.
    /// - Returns: A fully configured `URLRequest`.
    /// - Throws: `YFGNetworkError` if URL construction or body encoding fails.
    static func from(
        endpoint: YFGEndpoint,
        in environment: YFGEnvironment,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) throws -> URLRequest {
        
        // 1. Construct the full URL
        let url = environment.baseURL.appendingPathComponent(endpoint.path)
        
        var request = URLRequest(
            url: url,
            cachePolicy: endpoint.cachePolicy,
            timeoutInterval: 60 // A default, can be overridden by endpoint
        )
        
        // 2. Set HTTP Method
        request.httpMethod = endpoint.method.rawValue
        
        // 3. Set Headers
        endpoint.headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // 4. Handle Task (Parameters/Body)
        switch endpoint.task {
        case .requestPlain:
            break // No body or parameters
            
        case .requestParameters(let parameters):
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw YFGNetworkError.invalidURL
            }
            components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
            guard let finalURL = components.url else {
                throw YFGNetworkError.invalidURL
            }
            request.url = finalURL
            
        case .requestJSONEncodable(let encodable):
            do {
                let data = try jsonEncoder.encode(encodable)
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: YFGConstant.contentTypeHeader)
            } catch {
                throw YFGNetworkError.encodingFailed(error)
            }
            
        case .requestData(let data):
            request.httpBody = data
            
        case .requestMultipart(let formDataParts):
            let boundary = "YFGBoundary-\(UUID().uuidString)"
            request.setValue("\(YFGConstant.multipartFormData); boundary=\(boundary)", forHTTPHeaderField: YFGConstant.contentTypeHeader)
            request.httpBody = createMultipartBody(with: formDataParts, boundary: boundary)
        }
        
        return request
    }
    
    /// Creates the body for a multipart/form-data request.
    private static func createMultipartBody(with parts: [YFGMultipartFormData], boundary: String) -> Data {
        var body = Data()
        
        for part in parts {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("\(YFGConstant.contentdispositionHeader): form-data; name=\"\(part.name)\"".data(using: .utf8)!)
            
            if let fileName = part.fileName, let mimeType = part.mimeType {
                body.append("; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                body.append("\(YFGConstant.contentTypeHeader): \(mimeType)\r\n".data(using: .utf8)!)
            } else {
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("\r\n".data(using: .utf8)!)
            body.append(part.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
