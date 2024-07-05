//
//  FollowDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/30/24.
//

import Foundation
import Alamofire

class FollowListDataManager {
    
    static let shared = FollowListDataManager()
    
    func followerDataManager(_ handle : String, _ completion: @escaping ([MemberListDataModel]) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/follower"
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: FollowListDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                let resultData = result.result.memberList
                print(resultData)
                completion(resultData)
            case .failure(let error):
                print("Request Fail : followerDataManager")
                print(error)
            }
        }
    }
    
    func followingDataManager(_ handle : String, _ completion: @escaping ([MemberListDataModel]) -> Void) {
        
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/following"
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: FollowListDataResponse.self) { response in
            print(response)
            switch response.result {
            case .success(let result):
                let resultData = result.result.memberList
                completion(resultData)
            case .failure(let error):
                print("Request Fail : followingDataManager")
                print(error)
            }
        }
    }
}
