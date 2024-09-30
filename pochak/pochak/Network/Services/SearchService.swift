//
//  SearchService.swift
//  pochak
//
//  Created by 장나리 on 8/25/24.
//

import Foundation

struct SearchService {
    /// 아이디 검색 데이터 받아오는 함수
    /// - Parameters:
    ///   - request: 받아올 아이디
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func getSearch(
        request: SearchRequest,
        completion: @escaping (_ succeed: SearchResponse?, _ failed: NetworkError?) -> Void) {
        NetworkService.shared.request(SearchAPI.getSearch(request)) { response in
            switch response {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                print("=== getSearch error ===")
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
}
