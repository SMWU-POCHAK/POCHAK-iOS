//
//  UserService.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/10/24.
//

import Foundation

struct UserService {
    
    /// 팔로우 요청 혹은 취소하기
    /// - Parameters:
    ///   - handle: 팔로우 요청 혹은 취소하려는 사용자의 핸들 (아이디)
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func postFollowRequest(
        handle: String,
        completion: @escaping (_ succeed: FollowResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(FollowAPI.postFollowRequest(handle)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postFollowRequest service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 팔로우 요청 혹은 취소하기
    /// - Parameters:
    ///   - handle: 팔로우 요청 혹은 취소하려는 사용자의 핸들 (아이디)
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func blockUser(
        handle: String,
        completion: @escaping (_ succeed: BlockResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(BlockAPI.blockUser(handle)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== blockUser service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 팔로우 요청 혹은 취소하기
    /// - Parameters:
    ///   - handle: 팔로우 요청 혹은 취소하려는 사용자의 핸들 (아이디)
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func unblockUser(
        handle: String,
        request: UnblockRequest,
        completion: @escaping (_ succeed: UnblockResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(UnblockAPI.unblockUser(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== unblockUser service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
