//
//  LogoutDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//
import Alamofire

class LogoutDataManager{
    
    static let shared = LogoutDataManager()
    
    // Get token
    let accessToken = GetToken.getAccessToken()
    let refreshToken = GetToken.getRefreshToken()
    
    
    func logoutDataManager(_ completion: @escaping (LogoutDataModel) -> Void) {
        let url = "\(APIConstants.baseURL)/api/v2/member/logout"
        
        print("accessToken : \(accessToken)")
        print("refreshToken : \(refreshToken)")

        
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
        .responseDecodable(of: LogoutDataModel.self) { response in
            switch response.result {
            case .success(let result):
                print("logout success!!!!!!!!!")
                let resultData = result
                completion(resultData)
            case .failure(let error):
                print("Request Fail : logoutDataManager")
                print(error)
            }
        }
    }
}
