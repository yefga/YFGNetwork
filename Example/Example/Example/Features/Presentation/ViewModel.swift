//
//  ViewModel.swift
//  YFGNetwork
//
//  Created by Yefga on 30/07/25.
//

import Combine

@MainActor
final class ViewModel: ObservableObject {
    @Published var detail: Response?
    @Published var error: String?

    private let useCase: UseCaseInterface

    init(useCase: UseCaseInterface) {
        self.useCase = useCase
    }

    func load(kanji: String) async {
        let result = await useCase.getKanji(from: kanji)
        switch result {
        case .success(let entity):
            self.detail = entity
        case .failure(let err):
            self.error = err.message
        }
    }
}
