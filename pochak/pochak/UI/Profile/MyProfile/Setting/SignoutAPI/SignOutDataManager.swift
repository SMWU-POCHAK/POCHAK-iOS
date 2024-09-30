//
//  DeleteAccountDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Alamofire

class SignOutDataManager{
    
    static let shared = SignOutDataManager()
    
    func signOutDataManager(_ completion: @escaping (SignOutDataModel) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/signout"

        AF.request(url,
                   method: .delete,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: SignOutDataModel.self) { response in
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
