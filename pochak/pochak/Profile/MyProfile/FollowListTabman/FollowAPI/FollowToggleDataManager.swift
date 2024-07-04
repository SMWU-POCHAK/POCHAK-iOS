//
//  FollowToggleDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/30/24.
//

import Foundation
import Alamofire

class FollowToggleDataManager {
    
    static let shared = FollowToggleDataManager()
    
    func followToggleDataManager(_ handle : String, _ completion: @escaping (FollowToggleDataResponse) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/follow"

        AF.request(url,
                   method: .post,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: FollowToggleDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print("Request Fail : followToggleDataManager")
                print(error)
            }
        }
    }
}
