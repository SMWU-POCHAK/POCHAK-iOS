//
//  MyProfilePostDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 12/28/23.
//

import Alamofire

class MyProfilePostDataManager {
    
    static let shared = MyProfilePostDataManager()
    
    // Get token
    let accessToken = GetToken.getAccessToken()
    let refreshToken = GetToken.getRefreshToken()
    
    func myProfileUserAndPochakedPostDataManager(_ handle : String, _ completion: @escaping (MyProfileUserAndPochakedPostModel) -> Void) {
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)"
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
        .responseDecodable(of: MyProfileUserAndPochakedPostResponse.self) { response in
            print(response)
            switch response.result {
            case .success(let result):
                let resultData = result.result
                completion(resultData)
            case .failure(let error):
                print("Request Fail : myProfileUserAndPochakedPostDataManager")
                print(error)
            }
        }
    }
    
    func myProfilePochakPostDataManager(_ handle : String, _ completion: @escaping ([PostDataModel]) -> Void) {
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/upload"
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
        .responseDecodable(of: MyProfilePochakPostResponse.self) { response in
            print(response)
            switch response.result {
            case .success(let result):
                let resultData = result.result.postList
                completion(resultData)
            case .failure(let error):
                print("Request Fail : myProfilePochakPostDataManager")
                print(error)
            }
        }
    }
}
