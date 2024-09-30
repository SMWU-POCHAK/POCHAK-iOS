//
//  AppleLoginDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 7/1/24.
//

import Foundation
import Alamofire

class AppleLoginDataManager {
    
    static let shared = AppleLoginDataManager()
    
    func appleLoginDataManager(_ IdentityToken : String, _ authorizationCode : String, _ completion: @escaping (AppleLoginModel) -> Void) {
        let url = "\(APIConstants.baseURL)/apple/login"
        let header : HTTPHeaders = ["IdentityToken": IdentityToken, "AuthorizationCode" : authorizationCode]

        print(">>>>> appleLoginDataManager url == \(url)")
        print(">>>>> appleLoginDataManager header == \(header)")
        AF.request(url, method: .post, headers: header).validate().responseDecodable(of: AppleLoginResponse.self) { response in
            print(response.result)
               switch response.result {
               case .success(let result):
                   let resultData = result.result
                   print(result)
                   completion(resultData)
               case .failure(let error):
                   print("appleLoginDataManager error : \(error.localizedDescription)")
                   if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                       print("Failure Data: \(errorMessage)")
                   }
               }
           }
    }
}
