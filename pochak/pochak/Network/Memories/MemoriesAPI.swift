//
//  MemoriesAPI.swift
//  pochak
//
//  Created by Haru on 10/14/24.
//

import Foundation
import Alamofire

enum MemoriesAPI {
    case getMemoriesSummary(_ id: String)
    case getPochakMemoryList(_ id: String)
    case getPochakedMemoryList(_ id: String)
    case getBondedMemoryList(_ id: String)
}

extension MemoriesAPI: BaseAPI {
    typealias Response = MemorySummary
    
    var method: HTTPMethod {
        switch self {
        case .getMemoriesSummary,
                .getPochakMemoryList,
                .getPochakedMemoryList,
                .getBondedMemoryList:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getMemoriesSummary(let id):
            return "/v1/memories/\(id)"
        case .getPochakMemoryList(let id):
            return "v1/memories/\(id)/pochak"
        case .getPochakedMemoryList(let id):
            return "v1/memories/\(id)/pochaked"
        case .getBondedMemoryList(let id):
            return "v1/memories/\(id)/bonded"
        }
    }
}
