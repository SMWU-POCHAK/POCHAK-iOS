//
//  BlockedUserListDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 7/5/24.
//

import Foundation
import Alamofire

class BlockedUserListDataManager{
    
    static let shared = BlockedUserListDataManager()
    
    func blockedUserListDataManager(_ handle : String,_ page : Int, _ completion: @escaping (BlockedUserDataModel) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/block?page=\(page)"
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: BlockedUserDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                let resultData = result.result
                print(">>>>> resultData : \(resultData)")
                completion(resultData)
            case .failure(let error):
                print("Request Fail : blockedUserListDataManager")
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
}
