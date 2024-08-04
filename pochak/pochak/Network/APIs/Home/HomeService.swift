//
//  HomeAPI.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation

struct HomeService {
    static func getHomePost(request: HomeRequest, completion: @escaping (_ succeed: HomeResponse?, _ failed: Error?) -> Void) {
        NetworkService.shared.request(HomeAPI.getHomePost(request)){ response  in
            switch response {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
