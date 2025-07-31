
<p align="center">

<p align="center">
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/swift-5.5+-brightgreen.svg"/></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-ready-orange.svg"></a>
<a href="#"><img src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
<a href="https://en.wikipedia.org/wiki/IOS_13"><img src="https://img.shields.io/badge/iOS-13-blue.svg"></a>
<a href="https://www.apple.com/id/macos/macos-sequoia/"><img src="https://img.shields.io/badge/macOS-15-purple.svg"></a>

</p>


A modern, clean, and testable networking layer for iOS and macOS, built with Swift's `async/await`.

## Overview

YFGNetwork is a lightweight yet powerful networking framework built with Domain-Driven Design in mind. It’s designed to help you focus on building features, not fighting boilerplate. With type-safe API definitions and built-in support for things like request interception, response validation, and automatic retries, it takes care of the boring stuff so you can move faster.

## Features

✅ **Modern Concurrency:** Built entirely on `async/await` for clean, readable asynchronous code.
    
✅ **Type-Safe Endpoints:** Define your API endpoints safely using enums.
    
✅ **SOLID Principles:** Designed for testability and scalability from the ground up.
    
✅ **Request Interception:** Easily add authentication tokens or common headers to requests.
    
✅ **Response Validation:** Automatic validation of status codes and response data.
    
✅ **Automatic Retries:** Configurable retry policies for handling transient network failures.
    
✅ **Detailed Logging:** A built-in logger for easy debugging of network traffic.
    
✅ **Multipart & Data Uploads:** Full support for complex uploads.
    
✅ **File Downloads:** Simple API for downloading files directly to a destination.
    


    

## Installation

### Swift Package Manager

You can add YFGNetwork to your project by adding it as a package dependency in Xcode or your `Package.swift` file.

1. In Xcode, go to **File > Add Packages...**
    
2. Enter the repository URL: `https://github.com/Yefga/YFGNetwork.git`
        

Or, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "[https://github.com/Yefga/YFGNetwork.git](https://github.com/Yefga/YFGNetwork.git)", from: "0.0.1")
]
```

### CocoaPods

To install with CocoaPods, add the following line to your `Podfile`:

```ruby
pod 'YFGNetwork'
```

Then, run `pod install`.

## How to Use

### 1. Define Your API Environment
Create a struct that conforms to `YFGEnvironment` to specify the base URL for your API.

```swift
import YFGNetwork

struct APIEnvironment: YFGEnvironment {
    var baseURL: URL {
        return URL(string: "[https://api.example.com/v1](https://api.example.com/v1)")!
    }
}
```

### 2. Define Your Endpoints

Create an enum that conforms to `YFGEndpoint`. This is where you define all the specifics for each API call.

```swift
import YFGNetwork

enum MyAPI {
    case getPublicPosts
    case getUserProfile(userId: String)
    case updateUser(userId: String, name: String)
}

extension MyAPI: YFGEndpoint {
    var path: String {
        switch self {
        case .getPublicPosts:
            return "/posts"
        case .getUserProfile(let userId):
            return "/users/\(userId)"
        case .updateUser(let userId, _):
            return "/users/\(userId)"
        }
    }

    var method: YFGHTTPMethod {
        switch self {
        case .getPublicPosts, .getUserProfile:
            return .get
        case .updateUser:
            return .patch
        }
    }

    var task: YFGTask {
        switch self {
        case .getPublicPosts, .getUserProfile:
            return .requestPlain
        case .updateUser(_, let name):
            let params = ["name": name]
            return .requestJSONEncodable(params)
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var needsInterceptor: Bool {
        switch self {
        case .getPublicPosts:
            return false
        case .getUserProfile, .updateUser:
            return true
        }
    }    
}
```

### 3. Create the Network Service

Instantiate `YFGNetworkService` with your environment. You can also inject custom interceptors, loggers, or validators.

```swift
import YFGNetwork

let networkService = YFGNetwork(environment: APIEnvironment())
```

### 4. Make a Request

First, define the data models you expect from the API.
```swift
struct UserProfile: Decodable {
    let id: String?
    let name: String?
    let email: String?
}

struct ErrorResponse: Decodable {
    let message: String?
}
```
Use an `async` function to call the service and handle the response.
```swift
    let result = await network.request(Endpoint.getUserProfile), responseType: UserProfile.self, errorType: ErrorResponse.self)
        
    switch result {
        case .success(let dto):
            return .success(dto)
        case .failure(let error):
            if let model = try? error.mappedToModel(ErrorResponse.self) {
                return .failure(model)
        }
        return .failure(.init())
    }
```
___

### Advanced: Custom Request Interceptor (Optional)

For tasks like refreshing authentication tokens, you can provide a custom interceptor.

```swift
class TokenInterceptor: YFGRequestInterceptor {
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request        
        let token = await authManager.getValidToken()
        
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
}
```

## License
YFGNetwork is released under the MIT license. See [LICENSE](https://github.com/yefga/YFGNetwork/blob/main/LICENSE) for details.

### Contribution
YFGNetwork is fully open-source. All suggestions and contributions are welcome!