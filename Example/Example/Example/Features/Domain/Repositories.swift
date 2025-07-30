//
//  Repositories.swift
//  YFGNetwork
//
//  Created by Yefga on 30/07/25.
//

import YFGNetwork
import Foundation

protocol RepositoriesInterface {
    func getKanji(from character: String) async -> Result<Response, ErrorResponse>
}

class Repositories {
    private let network: YFGNetworkProtocol

    init(network: YFGNetworkProtocol) {
        self.network = network
    }
}

extension Repositories: RepositoriesInterface {
    func getKanji(from character: String) async -> Result<Response, ErrorResponse> {
        let result = await network.request(
            Endpoint.kanji(kanji: character),
            responseType: Response.self,
            errorType: ErrorResponse.self 
        )
        
        switch result {
        case .success(let dto):
            return .success(dto)
        case .failure(let error):
            if let model = try? error.mappedToModel(ErrorResponse.self) {
                return .failure(model)
            }
            return .failure(.init())
        }
    }
}
