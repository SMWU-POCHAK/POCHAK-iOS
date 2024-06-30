//
//  Authenticator.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Alamofire

struct TokenRefreshResponse: Codable {
    let isSuccess: Bool
    let code: Int
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
        
    // api요청 시 AuthenticatorIndicator객체가 존재하면, 요청 전에 가로채서 apply에서 Header에 bearerToken 추가
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        print("1. apply Function 실행중")
        print("1. apply Function 실행중 현재 토큰 : \(accessToken)")
        urlRequest.addValue(accessToken, forHTTPHeaderField: "Authorization")
//        urlRequest.addValue("Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkeHh5bm5pIiwicm9sZSI6IlJPTEVfVVNFUiIsImlhdCI6MTcwNTYyMDMwOCwiZXhwIjoxNzgzMzgwMzA4fQ.2u1cQI59e1n9yPEeCiJxuocU6CR9eMIPRTfJgkFJzX4", forHTTPHeaderField: "Authorization")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
        print(urlRequest.headers)
    }
    
    // api요청 후 error가 떨어진 경우, 401에러(인증에러)인 경우만 refresh가 되도록 필터링
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        print("didRequest Function 실행중~~~~~!!")
//        if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//            print("Failure Data: \(errorMessage)")
//        }
        print(response, "부분입니다~~~")
        print(error)
        print(response.statusCode)
        return response.statusCode == 401
    }
    
    // 인증이 필요한 urlRequest에 대해서만 refresh가 되도록, 이 경우에만 true를 리턴하여 refresh 요청
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: MyAuthenticationCredential) -> Bool {
        // bearerToken의 urlRequest대해서만 refresh를 시도 (true)
        print("isRequest Function 실행중~~~~~!!")
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        let startIndex = bearerToken.index(bearerToken.startIndex, offsetBy: 7)
        let newBearerToken = String(bearerToken[startIndex...]) // 12:00:00
        print("beartoken이 맞는건지 확인합니다~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", newBearerToken)
        return urlRequest.headers["Authorization"] == newBearerToken
    }
    
    // token을 refresh하는 부분
    func refresh(_ credential: MyAuthenticationCredential, for session: Alamofire.Session, completion: @escaping (Result<MyAuthenticationCredential, Error>) -> Void) {
        
        // refreshtoken 만료 시 로그아웃 하도록!!
        
        print("refresh Function 실행중~~~~~!!")

        let url = APIConstants.baseURL + "/api/v1/user/refresh"
        let header : HTTPHeaders = ["Authorization": accessToken, "RefreshToken" : refreshToken, "Content-type": "application/json"]
        
        AF.request(url,
                   method: .post,
                   encoding: URLEncoding.default)
        .validate()
        .responseDecodable(of: TokenRefreshResponse.self) { response in
               switch response.result {
               case .success(let result):
                   print(result.message)
                   print("inside Refresh Success!!!!")
                   let newAccessToken = result.result.accessToken
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
