//
//  BlockDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 6/30/24.
//

import Foundation
import Alamofire

class BlockDataManager {
    
    static let shared = BlockDataManager()
    
    func blockDataManager(_ handle : String, _ completion: @escaping (BlockDataResponse) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/block"

        AF.request(url,
                   method: .post,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: BlockDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print("Request Fail blockDataManager : \(error.localizedDescription)")
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
}
