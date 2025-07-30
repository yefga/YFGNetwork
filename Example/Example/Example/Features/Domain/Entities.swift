//
//  Entities.swift
//  YFGNetwork
//
//  Created by Yefga on 30/07/25.
//

import Foundation

struct Response: Decodable {
    var freqMainichiShinbun, grade: Int?
    var heisigEn: String?
    var jlpt: Int?
    var kanji: String?
    var kunReadings, meanings, nameReadings: [String]?
    var notes: [String]?
    var onReadings: [String]?
    var strokeCount: Int?
    var unicode: String?
    
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case freqMainichiShinbun = "freq_mainichi_shinbun"
        case grade
        case heisigEn = "heisig_en"
        case jlpt
        case kanji
        case kunReadings = "kun_readings"
        case meanings
        case nameReadings = "name_readings"
        case notes
        case strokeCount = "stroke_count"
        case onReadings = "on_readings"        
    }
}

struct ErrorResponse: Decodable, Error {
    var message: String?
}
