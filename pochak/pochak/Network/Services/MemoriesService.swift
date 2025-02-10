//
//  MemoriesService.swift
//  pochak
//
//  Created by Haru on 12/30/24.
//

import Foundation

struct MemoriesService {
    static let networkService = NetworkService.shared
    
    /// 추억페이지 데이터 조회
    /// - Parameters:
    ///   - userId: 추억페이지 조회하고자 하는 상대 유저 아이디
    ///   - completion: 핸들러
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
    
    /// 추억 갤러리 페이지에서 POCHAK 게시물 조회
    /// - Parameters:
    ///   - userId: 추억페이지 조회하고자 하는 상대 유저 아이디
    ///   - completion: 핸들러
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
                print("=== getMemoriesPochak service error ===")
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    /// 추억 갤러리 페이지에서 POCHAKED 게시물 조회
    /// - Parameters:
    ///   - userId: 추억페이지 조회하고자 하는 상대 유저 아이디
    ///   - completion: 핸들러
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
    
    /// 추억 갤러리 페이지에서 BONDED 게시물 조회
    /// - Parameters:
    ///   - userId: 추억페이지 조회하고자 하는 상대 유저 아이디
    ///   - completion: 핸들러
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
