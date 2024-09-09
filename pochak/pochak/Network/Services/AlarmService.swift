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
            NetworkService.shared.request(AlarmListAPI.getAlarmList(request)) { response in
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
    
    
    /// 태그 알림 미리보기 조회
    /// - Parameters:
    ///   - alarmId: 미리보기 할 알람 아이디
    ///   - completion: 핸들러
    static func getTagPreview(
        alarmId: Int,
        completion: @escaping (_ succeed: TagPreviewResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(TagPreviewAPI.getTagPreview(alarmId)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getTagPreview service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    
    /// 태그 수락 , 거절
    /// - Parameters:
    ///   - tagId: 태그 아이디
    ///   - request: isAccept - 수락 여부
    ///   - completion: 핸들러
    static func postTagApprove(
        tagId: Int,
        request: TagApproveRequest,
        completion: @escaping (_ succeed: TagApproveResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(TagApproveAPI.postTagApprove(tagId: tagId, tagApproveRequest: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postTagApprove service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
    
