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
    
    // Get token
    let accessToken = GetToken().getAccessToken()
    let refreshToken = GetToken().getRefreshToken()
    
    func unBlockDataManager(_ handle : String, _ completion: @escaping (UnBlockDataResponse) -> Void) {
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/block"

        let authenticator = MyAuthenticator()
        let credential = MyAuthenticationCredential(accessToken: accessToken,
                                                    refreshToken: refreshToken,
                                                    expiredAt: Date(timeIntervalSinceNow: 60 * 60))
        let myAuthencitationInterceptor = AuthenticationInterceptor(authenticator: authenticator,
                                                                    credential: credential)
        AF.request(url,
                   method: .delete,
                   encoding: URLEncoding.default,
                   interceptor: myAuthencitationInterceptor)
        .validate()
        .responseDecodable(of: UnBlockDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print("Request Fail : unBlockDataManager")
                print(error)
            }
        }
    }
}
