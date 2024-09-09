//
//  AlarmService.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation

struct AlarmService {
    /// 알람 리스트 조회
    /// - Parameters:
    ///   - postId: 상세 조회하고자 하는 게시글 아이디
    ///   - completion: 핸들러
    static func getAlarmList(
        request: AlarmListRequest,
        completion: @escaping (_ succeed: AlarmListResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(AlarmAPI.getAlarmList(request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getAlarmList service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
    
