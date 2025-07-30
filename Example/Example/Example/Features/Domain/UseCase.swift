//
//  UseCase.swift
//  YFGNetwork
//
//  Created by Yefga on 30/07/25.
//
import YFGNetwork
import Foundation

protocol UseCaseInterface {
    func getKanji(from character: String) async -> Result<Response, ErrorResponse>
}

class UseCase: UseCaseInterface {
  
    private let repository: RepositoriesInterface
    
    init(repository: RepositoriesInterface) {
        self.repository = repository
    }
    
    func getKanji(from character: String) async -> Result<Response, ErrorResponse> {
        return await repository.getKanji(from: character)
    }
}
