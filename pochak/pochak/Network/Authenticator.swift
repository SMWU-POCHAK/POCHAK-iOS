//
//  Authenticator.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Alamofire

// MARK: - Token Refresh Data Model
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
    let accessToken = GetToken.getAccessToken()
    let refreshToken = GetToken.getRefreshToken()
    typealias Credential = MyAuthenticationCredential
        
    // 1. api요청 시 AuthenticatorIndicator객체가 존재하면, 요청 전에 가로채서 apply에서 Header에 bearerToken 추가
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        print("--------------- 1. apply Function 실행 중 ---------------")
        print(">>>>> apply 현재 토큰 : \(accessToken)")
        urlRequest.addValue(credential.accessToken, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(">>>>> apply 현재 urlRequest : \(urlRequest)")
        
    }
    
    // 2. api요청 후 error가 떨어진 경우, 401에러(인증에러)인 경우만 refresh가 되도록 필터링
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        print("--------------- 2. didRequest Function 실행 중 ---------------")
//        if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//            print("Failure Data: \(errorMessage)")
//        }
        print(">>>>> didRequest 현재 response : \(response)")
        print(">>>>> didRequest 현재 statusCode : \(response.statusCode)")
        print(">>>>> didRequest 현재 error : \(error)")
        return response.statusCode == 401
    }
    
    // 3. 인증이 필요한 urlRequest에 대해서만 refresh가 되도록, 이 경우에만 true를 리턴하여 refresh 요청
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: MyAuthenticationCredential) -> Bool {
        // bearerToken의 urlRequest대해서만 refresh를 시도 (true)
        print("--------------- 3. isRequest Function 실행 중 ---------------")
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        let startIndex = bearerToken.index(bearerToken.startIndex, offsetBy: 7)
        let newBearerToken = String(bearerToken[startIndex...]) // 12:00:00
        print(">>>>> headers bearerToken: \(urlRequest.headers["Authorization"])")
        print(">>>>> bearerToken : \(newBearerToken)")
        print(">>>>> bearerToken이 맞는건지 확인합니다 : \(urlRequest.headers["Authorization"] == newBearerToken)")
        return urlRequest.headers["Authorization"] == newBearerToken
    }
    
    // 4. accesToken을 refresh 하는 부분
    // 추가 할 것 :: refreshtoken 만료 시 로그아웃 하도록 처리(유효기간 1달)
    func refresh(_ credential: MyAuthenticationCredential, for session: Alamofire.Session, completion: @escaping (Result<MyAuthenticationCredential, Error>) -> Void) {
        print("--------------- 4. refresh Function 실행 중 ---------------")
        let url = "\(APIConstants.baseURL)/api/v2/refresh"
        let header : HTTPHeaders = ["Authorization": accessToken, "RefreshToken" : refreshToken, "Content-type": "application/json"]
        
        print(">>>>> url : \(url)")
        print(">>>>> header : \(header)")
        AF.request(url, method: .post, headers: header).validate().responseDecodable(of: TokenRefreshResponse.self) { response in
               switch response.result {
               case .success(let result):
                   print(result.message)
                   print("inside Refresh Success!!!!")
                   let newAccessToken = result.result.accessToken
                   print(newAccessToken)
                   do {
                       try KeychainManager.update(account: "accessToken", value: newAccessToken)
                   } catch {
                       print(error)
                   }
                   let credential = Credential(accessToken: newAccessToken, refreshToken: credential.refreshToken, expiredAt: Date(timeIntervalSinceNow: 60 * 60))
                   completion(.success(credential))
               case .failure(let error):
                   print("inside Refresh Fail!!!!")
                   print(error)
               }
           }
    }
}
