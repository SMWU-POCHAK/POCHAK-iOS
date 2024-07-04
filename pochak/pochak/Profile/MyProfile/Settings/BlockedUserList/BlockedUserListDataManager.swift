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
    
    
    func blockedUserListDataManager(_ handle : String, _ completion: @escaping (BlockedUserDataModel) -> Void) {
        // Get token
        let accessToken = GetToken.getAccessToken()
        let refreshToken = GetToken.getRefreshToken()
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/block"
        
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
        .responseDecodable(of: BlockedUserDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                let resultData = result.result
                print(">>>>> resultData : \(resultData)")
                completion(resultData)
            case .failure(let error):
                print("blockedUserListDataManager error : \(error.localizedDescription)")
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
}
