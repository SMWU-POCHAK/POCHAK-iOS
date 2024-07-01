//
//  TagDataService.swift
//  pochak
//
//  Created by 장나리 on 12/27/23.
//

import Foundation
import Alamofire

class SearchDataService{
    
    static let shared = SearchDataService()
    
    func getIdSearch(keyword:String,completion: @escaping(NetworkResult<Any>) -> Void){
        let parameters: [String: Any] = ["keyword": keyword]
        let header : HTTPHeaders = ["Authorization": APIConstants.suyeonToken,
                                    "Content-type": "application/json"
                                    ]
        print("==getIdSearch==")
        print(parameters)
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/members/search?keyword=\(keyword)",
                                     method: .get,
                                     encoding: URLEncoding.default,
                                     headers: header)
        
        dataRequest.responseJSON { response in
            switch response.result {
            case .success(let value): // 데이터 통신이 성공한 경우
                print(value)
                
                guard let json = value as? [String: Any],
                      let result = json["result"] as? [String: Any],
                      let jsonArray = result["memberList"] as? [[String: Any]] else {
                    completion(.networkFail)
                    return
                }
                
                var searchData = [idSearchResponse]()
                
                for dict in jsonArray {
                    if let profileUrl = dict["profileImage"] as? String,
                       let handle = dict["handle"] as? String,
                       let memberId = dict["memberId"] as? Int, // memberId는 Int 타입
                       let name = dict["name"] as? String {

                        let searchDataItem = idSearchResponse(memberId: "\(memberId)", profileImage: profileUrl, handle: handle, name: name)
                        searchData.append(searchDataItem)
                    }
                }
                
                print(searchData)
                completion(.success(searchData))
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("Failure Status Code: \(statusCode)")
                }
                print("Failure Error: \(error.localizedDescription)")
                
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
                completion(.networkFail)
            }
        }
    }
}
