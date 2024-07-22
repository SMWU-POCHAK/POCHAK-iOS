//
//  BlockDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 6/30/24.
//

import Foundation
import Alamofire

class UnBlockDataManager {
    
    static let shared = UnBlockDataManager()
    
    func unBlockDataManager(_ handle : String, _ blockedMemberHandle : String, _ completion: @escaping (UnBlockDataResponse) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/block?blockedMemberHandle=\(blockedMemberHandle)"

        AF.request(url,
                   method: .delete,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: UnBlockDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print("Request Fail unBlockDataManager : \(error.localizedDescription)")
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
}
