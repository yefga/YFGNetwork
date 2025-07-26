//
//  YFGRetryPolicy.swift
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

public struct YFGRetryPolicy {
    public let maxAttempts: Int
    public let initialDelay: TimeInterval
    public let delayStrategy: DelayStrategy
    public let waitForConnectivity: Bool
    
    public enum DelayStrategy {
        case exponential
        case linear
        case constant
    }
    
    public init(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        delayStrategy: DelayStrategy = .exponential,
        waitForConnectivity: Bool = false
    ) {
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.delayStrategy = delayStrategy
        self.waitForConnectivity = waitForConnectivity
    }
}
