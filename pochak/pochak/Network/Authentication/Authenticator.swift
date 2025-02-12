//
//  Authenticator.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import UIKit
import Alamofire

struct TokenRefreshResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TokenRefreshDataModel
}

struct TokenRefreshDataModel: Codable {
    let accessToken : String
}

class MyAuthenticator : Authenticator {
    typealias Credential = MyAuthenticationCredential
    
    // 1. api요청 시 AuthenticatorIndicator객체가 존재하면, 요청 전에 가로채서 apply에서 Header에 bearerToken 추가
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        urlRequest.addValue(credential.accessToken, forHTTPHeaderField: "Authorization")
    }
    
    // 2. api요청 후 error가 떨어진 경우, 401에러(인증에러)인 경우만 refresh가 되도록 필터링
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        return response.statusCode == 401
    }
    
    // 3. 인증이 필요한 urlRequest에 대해서만 refresh가 되도록, 이 경우에만 true를 리턴하여 refresh 요청
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: MyAuthenticationCredential) -> Bool {
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        let startIndex = bearerToken.index(bearerToken.startIndex, offsetBy: 7)
        let newBearerToken = String(bearerToken[startIndex...])
        return urlRequest.headers["Authorization"] == newBearerToken
    }
    
    // 4. accesToken을 refresh
    func refresh(_ credential: MyAuthenticationCredential, for session: Alamofire.Session, completion: @escaping (Result<MyAuthenticationCredential, Error>) -> Void) {
        let url = "\(APIConstants.baseURL)/api/v2/refresh"
        let header : HTTPHeaders = ["Authorization": credential.accessToken,
                                    "RefreshToken" : credential.refreshToken,
                                    "Content-type": "application/json"]
        
        AF.request(url, method: .post, headers: header).validate().responseDecodable(of: TokenRefreshResponse.self) { response in
            switch response.result {
            case .success(let result):
                let newAccessToken = result.result.accessToken
                do {
                    try KeychainManager.update(account: "accessToken", value: newAccessToken)
                } catch {
                    print(error)
                }
                let credential = Credential(accessToken: GetToken.getAccessToken(), refreshToken: credential.refreshToken, expiredAt: Date(timeIntervalSinceNow: 60 * 30))
                completion(.success(credential))
            case .failure(let error):
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
}
