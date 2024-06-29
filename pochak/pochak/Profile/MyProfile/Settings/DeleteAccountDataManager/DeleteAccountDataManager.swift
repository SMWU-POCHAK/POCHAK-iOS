//
//  DeleteAccountDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Alamofire

class DeleteAccountDataManager{
    
    static let shared = DeleteAccountDataManager()
    
    func deleteAccountDataManager(_ completion: @escaping (DeleteAccountResponse) -> Void) {
        
        let url = APIConstants.baseURL + "/api/v1/user/signout"
        let accessToken = GetToken().getAccessToken()
        
        let header : HTTPHeaders = ["Authorization": accessToken, "Content-type": "application/json"]
        print(header[0])
        
        AF.request(url,
                   method: .delete,
                   encoding: URLEncoding.default,
                   headers: header)
        .validate()
        .responseDecodable(of: DeleteAccountResponse.self) { response in
            switch response.result {
            case .success(let result):
                let resultData = result
                completion(resultData)
            case .failure(let error):
                print(error)
            }
        }
    }
}

