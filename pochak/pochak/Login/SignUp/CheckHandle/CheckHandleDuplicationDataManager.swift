//
//  CheckHandleDuplicationDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 7/3/24.
//

import Foundation
import Alamofire

class CheckHandleDuplicationDataManager{
    
    static let shared = CheckHandleDuplicationDataManager()
    
    func checkHandleDuplicationDataManager(_ handle : String, _ completion: @escaping (CheckHandleDuplicationResponse) -> Void) {
        let url = "\(APIConstants.baseURL)/api/v2/members/duplicate?handle=\(handle)"

        print("url ; \(url)")
        AF.request(url, method: .get).validate().responseDecodable(of: CheckHandleDuplicationResponse.self) { response in
               switch response.result {
               case .success(let result):
                   let resultData = result
                   print(result)
                   completion(resultData)
               case .failure(let error):
                   print("checkHandleDuplicationDataManager error : \(error)")
                   if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                       print("Failure Data: \(errorMessage)")
                   }
               }
           }
    }
}

