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
    
    // Get token
    let accessToken = GetToken().getAccessToken()
    let refreshToken = GetToken().getRefreshToken()
    
    
    func followToggleDataManager(_ handle : String, _ completion: @escaping (FollowToggleDataResponse) -> Void) {
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/follow"
        let authenticator = MyAuthenticator()
        let credential = MyAuthenticationCredential(accessToken: accessToken,
                                                    refreshToken: refreshToken,
                                                    expiredAt: Date(timeIntervalSinceNow: 60 * 60))
        let myAuthencitationInterceptor = AuthenticationInterceptor(authenticator: authenticator,
                                                                    credential: credential)
        AF.request(url,
                   method: .post,
                   encoding: URLEncoding.default,
                   interceptor: myAuthencitationInterceptor)
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
