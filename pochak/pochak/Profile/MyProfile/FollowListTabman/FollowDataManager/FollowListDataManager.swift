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
        
        // Get token
        let accessToken = GetToken.getAccessToken()
        let refreshToken = GetToken.getRefreshToken()
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/follower"
        let authenticator = MyAuthenticator()
        let credential = MyAuthenticationCredential(accessToken: accessToken,
                                                    refreshToken: refreshToken,
                                                    expiredAt: Date(timeIntervalSinceNow: 60 * 60))
        let myAuthencitationInterceptor = AuthenticationInterceptor(authenticator: authenticator,
                                                                    credential: credential)
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: myAuthencitationInterceptor)
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
        // Get token
        let accessToken = GetToken.getAccessToken()
        let refreshToken = GetToken.getRefreshToken()
        
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/following"
        let authenticator = MyAuthenticator()
        let credential = MyAuthenticationCredential(accessToken: accessToken,
                                                    refreshToken: refreshToken,
                                                    expiredAt: Date(timeIntervalSinceNow: 60 * 60))
        let myAuthencitationInterceptor = AuthenticationInterceptor(authenticator: authenticator,
                                                                    credential: credential)
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: myAuthencitationInterceptor)
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
