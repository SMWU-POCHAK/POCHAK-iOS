//
//  DeleteAccountDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Alamofire

class DeleteAccountDataManager{
    
    static let shared = DeleteAccountDataManager()
    
    // Get token
    let accessToken = GetToken.getAccessToken()
    let refreshToken = GetToken.getRefreshToken()
    
    func deleteAccountDataManager(_ completion: @escaping (DeleteAccountModel) -> Void) {
        let url = "\(APIConstants.baseURL)/api/v2/members/signout"
        
        print("accessToken : \(accessToken)")
        print("refreshToken : \(refreshToken)")

        
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
        .responseDecodable(of: DeleteAccountModel.self) { response in
            switch response.result {
            case .success(let result):
                print("signout success!!!!!!!!!")
                let resultData = result
                completion(resultData)
            case .failure(let error):
                print("Request Fail : deleteAccountDataManager")
                print(error)
            }
        }
    }
}

