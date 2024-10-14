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
            return "v2/memories/\(id)/pochak"
        case .getPochakedMemoryList(let id):
            return "v1/memories/\(id)/pochaked"
        case .getBondedMemoryList(let id):
            return "v1/memories/\(id)/bonded"
        }
    }
}

struct MemoriesService {
    static let networkService = NetworkService.shared
    
    static func getMemorySummary(
        userId: String,
        completion: @escaping ( Result<CommonResponse<MemorySummary>, NetworkError>
        ) -> Void
    ) {
        
        networkService.requestWithCommonResponse(MemoriesAPI.getMemoriesSummary(userId),
                                                 responseType: CommonResponse<MemorySummary>.self
        ) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("=== getMemorySummary service error ===")
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    static func getMemoriesPochak(
        userId: String,
        completion: @escaping ( Result<CommonResponse<MemoryList>, NetworkError>
        ) -> Void
    ) {
        
        networkService.requestWithCommonResponse(MemoriesAPI.getPochakMemoryList(userId),
                                                 responseType: CommonResponse<MemoryList>.self
        ) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("=== getMemorySummary service error ===")
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    static func getMemoriesPochaked(
        userId: String,
        completion: @escaping ( Result<CommonResponse<MemoryList>, NetworkError>
        ) -> Void
    ) {
        
        networkService.requestWithCommonResponse(MemoriesAPI.getPochakedMemoryList(userId),
                                                 responseType: CommonResponse<MemoryList>.self
        ) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("=== getMemoriesPochaked service error ===")
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    static func getMemoriesBonded(
        userId: String,
        completion: @escaping ( Result<CommonResponse<MemoryList>, NetworkError>
        ) -> Void
    ) {
        
        networkService.requestWithCommonResponse(MemoriesAPI.getBondedMemoryList(userId),
                                                 responseType: CommonResponse<MemoryList>.self
        ) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("=== getMemoriesBonded service error ===")
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
