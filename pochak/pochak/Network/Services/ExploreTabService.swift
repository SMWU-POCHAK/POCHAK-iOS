//
//  ExploreTabService.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation

struct ExploreTabService {
    /// 탐색 탭 게시글 데이터 받아오는 함수
    /// - Parameters:
    ///   - request: 받아올 탐색 탭 게시글 페이지
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func getExploreTab(
        request: ExploreTabRequest,
        completion: @escaping (_ succeed: ExploreTabResponse?, _ failed: NetworkError?) -> Void) {
        NetworkService.shared.request(ExploreTabAPI.getExploreTab(request)) { response in
            switch response {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                print("=== getExploreTab error ===")
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
}
