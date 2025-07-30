//
//  Endpoint.swift
//  Example
//
//  Created by Yefga on 30/07/25.
//

import YFGNetwork
import Foundation

enum Endpoint: YFGEndpoint {
    case kanji(kanji: String)
    
    var path: String {
        switch self {
        case .kanji(let kanji):
            return "/kanji/\(kanji)"
        }
    }
    
    var method: YFGHTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        nil
    }
    
    var task: YFGTask {
        .requestPlain
    }
    
    var timeoutInterval: TimeInterval {
        1.0
    }
}
