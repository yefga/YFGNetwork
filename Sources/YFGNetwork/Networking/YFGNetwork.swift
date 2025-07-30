//
//  YFGNetworkService.swift
//  YPNetwork
//
//  Created by Yefga on 26/07/25.
//

import Foundation
import Network

typealias Response = (Data, URLResponse)

public final class YFGNetwork {

    // MARK: - Dependencies
    
    private let environment: YFGEnvironment
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let interceptor: YFGRequestInterceptor
    private let validator: YFGResponseValidator
    private let logger: YFGLoggerProtocol
    private let networkMonitor: YFGNetworkMonitor
    
    // MARK: - Initialization
    
    /// Initializes the network service with all necessary dependencies.
    ///
    /// - Parameters:
    ///   - environment: The server environment (e.g., development, production).
    ///   - urlSession: The `URLSession` instance to use for requests. Defaults to a standard configuration.
    ///   - jsonDecoder: The `JSONDecoder` for parsing responses. Defaults to a standard instance.
    ///   - interceptor: The request interceptor. Defaults to `DefaultRequestInterceptor`.
    ///   - validator: The response validator. Defaults to `DefaultResponseValidator`.
    ///   - logger: The network logger. Defaults to `ConsoleLogger`.
    ///   - networkMonitor: The network connectivity monitor. Defaults to the shared instance.
    public init(
        environment: YFGEnvironment,
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        interceptor: YFGRequestInterceptor = DefaultRequestInterceptor(),
        validator: YFGResponseValidator = DefaultResponseValidator(),
        logger: YFGLoggerProtocol = YFGLogger(),
        networkMonitor: YFGNetworkMonitor = .shared
    ) {
        self.environment = environment
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.interceptor = interceptor
        self.validator = validator
        self.logger = logger
        self.networkMonitor = networkMonitor
    }
    
    private func performRequest<E: Decodable>(
        for endpoint: YFGEndpoint,
        errorType: E.Type
    ) async -> Result<Response, YFGErrorModel> {
        let retryPolicy = endpoint.retryPolicy
        var lastError: YFGErrorModel = YFGErrorModel(errorMessage: .unknown)

        for attempt in 1...retryPolicy.maxAttempts {
            do {
                await networkMonitor.waitForConnection()
                
                var request = try URLRequest.from(endpoint: endpoint, in: environment)
                
                // Conditionally adapt the request based on the endpoint's requirement.
                if endpoint.needsInterceptor {
                    request = try await interceptor.adapt(request)
                }
                
                logger.log(request: request)
                let (data, response) = try await urlSession.data(for: request)
                logger.log(response: response, data: data, error: nil, for: endpoint)
                
                let httpResponse = (response as? HTTPURLResponse)
                let httpStatusCode: Int = httpResponse?.statusCode ?? -1
                
                switch httpStatusCode {
                case 200...299:
                    try validator.validate(httpResponse)
                    return .success((data, response))
                    
                default:
                    let networkError = YFGNetworkError.mapStatusCodeToNetworkError(httpStatusCode)
                    let errorModel = YFGErrorModel(
                        errorCode: httpStatusCode,
                        errorMessage: networkError,
                        errorData: data
                    )
                    return .failure(errorModel)
                }
                
                
            } catch {
                if let networkError = error as? YFGNetworkError {
                    lastError = YFGErrorModel(errorMessage: networkError)
                } else {
                    lastError = YFGErrorModel(errorMessage: mapToNetworkError(error))
                }
                
                logger.log(response: nil, data: nil, error: error, for: endpoint)
                
                guard attempt < retryPolicy.maxAttempts else { break }
                
                let delay = calculateDelay(for: attempt, policy: retryPolicy)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        return .failure(lastError)
    }
    
    private func calculateDelay(for attempt: Int, policy: YFGRetryPolicy) -> TimeInterval {
        switch policy.delayStrategy {
        case .constant:
            return policy.initialDelay
        case .linear:
            return policy.initialDelay * Double(attempt)
        case .exponential:
            return policy.initialDelay * pow(2.0, Double(attempt - 1))
        }
    }
    
    private func mapToNetworkError(_ error: Error) -> YFGNetworkError {
        if let networkError = error as? YFGNetworkError {
            return networkError
        }
        
        switch (error as? URLError)?.code {
        case .notConnectedToInternet:
            return .noConnection
        case .timedOut:
            return .requestTimeout
        default:
            return .requestFailed(error)
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension YFGNetwork: YFGNetworkProtocol {
    public func request<T: Decodable, E: Decodable>(
            _ endpoint: YFGEndpoint,
            responseType: T.Type,
            errorType: E.Type
    ) async -> Result<T, YFGErrorModel> {
        let result = await performRequest(for: endpoint, errorType: errorType)
        switch result {
        case .success(let response):
            do {
                let decodedResponse = try jsonDecoder.decode(responseType, from: response.0)
                return .success(decodedResponse)
            } catch {
                let httpResponse = (response.1 as? HTTPURLResponse)

                return .failure(
                    YFGErrorModel(
                        errorCode: httpResponse?.statusCode,
                        errorMessage: .decodingFailed(error)
                    )
                )
            }
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    public func data(_ endpoint: YFGEndpoint) async throws -> Data {
        await networkMonitor.waitForConnection()
        var request = try URLRequest.from(endpoint: endpoint, in: environment)
        if endpoint.needsInterceptor {
            request = try await interceptor.adapt(request)
        }
        
        logger.log(request: request)
        let (data, response) = try await urlSession.data(for: request)
        logger.log(response: response, data: data, error: nil, for: endpoint)
        return data
    }
    
    public func download(_ endpoint: YFGEndpoint, to destination: URL) async throws -> URL {
        await networkMonitor.waitForConnection()
        
        var request = try URLRequest.from(endpoint: endpoint, in: environment)
        
        if endpoint.needsInterceptor {
            request = try await interceptor.adapt(request)
        }
        
        logger.log(request: request)
        
        do {
            // Use completion handler-based task wrapped in a continuation for backward compatibility.
            let (tempURL, response) = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(URL, URLResponse), Error>) in
                let task = urlSession.downloadTask(with: request) { url, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let response = response, let url = url else {
                        continuation.resume(throwing: YFGNetworkError.unknown)
                        return
                    }
                    continuation.resume(returning: (url, response))
                }
                task.resume()
            }
            
            logger.log(response: response, data: nil, error: nil, for: endpoint)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YFGNetworkError.badResponse(statusCode: -1)
            }
            
            try validator.validate(httpResponse)
            
            // Move file from temporary location to the desired destination, removing any existing item.
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: tempURL, to: destination)
            
            return destination
            
        } catch {
            logger.log(response: nil, data: nil, error: error, for: endpoint)
            throw mapToNetworkError(error)
        }
    }
    
    public func upload<T: Decodable>(_ endpoint: YFGEndpoint, from data: Data) async throws -> T {
        await networkMonitor.waitForConnection()

        var request = try URLRequest.from(endpoint: endpoint, in: environment)

        // Conditionally adapt the request based on the endpoint's requirement.
        if endpoint.needsInterceptor {
            request = try await interceptor.adapt(request)
        }
        
        logger.log(request: request)
        
        do {
            let (responseData, response) = try await urlSession.upload(for: request, from: data)
            logger.log(response: response, data: responseData, error: nil, for: endpoint)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YFGNetworkError.badResponse(statusCode: -1)
            }
            
            try validator.validate(httpResponse)
            
            return try jsonDecoder.decode(T.self, from: responseData)
            
        } catch {
            logger.log(response: nil, data: nil, error: error, for: endpoint)
            throw mapToNetworkError(error)
        }
    }
}
