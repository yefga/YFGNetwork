//
//  Environment.swift
//  YFGNetwork
//
//  Created by Yefga on 30/07/25.
//

import YFGNetwork
import Foundation

struct Environment: YFGEnvironment {
    var baseURL: URL {
        return URL(string: "https://kanjiapi.dev/v1/")!
    }
    init() { }
}
