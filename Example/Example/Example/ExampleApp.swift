//
//  ExampleApp.swift
//  Example
//
//  Created by Yefga on 30/07/25.
//

import SwiftUI
import YFGNetwork

@main
struct ExampleApp: App {
    var body: some Scene {
        
        let repository = Repositories(
            network: YFGNetwork(environment: Environment())
        )
        let useCase = UseCase(repository: repository)
        return WindowGroup {
            ContentView(
                viewModel: ViewModel(
                    useCase: useCase),
                    kanji: "走"
                )
        }
    }
}
