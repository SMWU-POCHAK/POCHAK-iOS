//
//  GoogleLoginDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import Alamofire

class GoogleLoginDataManager {
    
    static let shared = GoogleLoginDataManager()
    
    func googleLoginDataManager(_ accessToken : String, _ completion: @escaping (GoogleLoginModel) -> Void) {
        let url = "\(APIConstants.baseURL)/google/login/\(accessToken)"

        AF.request(url, method: .get).validate().responseDecodable(of: GoogleLoginResponse.self) { response in
               switch response.result {
               case .success(let result):
                   let resultData = result.result
                   completion(resultData)
               case .failure(let error):
                   print("googleLoginDataManager error")
                   print(error.localizedDescription)
               }
           }
    }
}
