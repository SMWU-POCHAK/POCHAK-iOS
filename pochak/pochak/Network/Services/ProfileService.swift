//
//  ProfileService.swift
//  pochak
//
//  Created by Seo Cindy on 9/18/24.
//

import Foundation

struct ProfileService {
    /// 홈 탭 게시글 데이터 받아오는 함수
    /// - Parameters:
    ///   - request: 받아올 홈 탭 게시글 페이지
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func getHomePost(
        request: HomeRequest,
        completion: @escaping (_ succeed: HomeResponse?, _ failed: NetworkError?) -> Void) {
        NetworkService.shared.request(HomeAPI.getHomePost(request)) { response in
            switch response {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                print("=== getHomePost error ===")
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
}
