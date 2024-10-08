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
    
    /// 팔로우 삭제하기
    /// - Parameters:
    ///   - handle: 현재 로그인한 유저의 핸들
    ///   - request : 삭제하려는 팔로워의 핸들
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func deleteFollower(
        handle: String,
        request: DeleteFollowerRequest,
        completion: @escaping (_ succeed: DeleteFollowerResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(DeleteFollowerAPI.deleteFollower(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== deleteFollower service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 팔로워 리스트 조회하기
    /// - Parameters:
    ///   - handle: 해당하는 핸들 유저의 팔로워 리스트 조회
    ///   - request : page 정보
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func getFollowers(
        handle: String,
        request: FollowListRequest,
        completion: @escaping (_ succeed: FollowListResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(FollowerRetrievalAPI.getFollowers(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getFollowers service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 팔로잉 리스트 조회하기
    /// - Parameters:
    ///   - handle: 해당하는 핸들 유저의 팔로잉 리스트 조회
    ///   - request : page 정보
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func getFollowings(
        handle: String,
        request: FollowListRequest,
        completion: @escaping (_ succeed: FollowListResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(FollowingRetrievalAPI.getFollowings(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getFollowings service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 유저 차단하기
    /// - Parameters:
    ///   - handle: 차단하고자 하는 사용자의 핸들 (아이디)
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
    
    /// 유저 차단 해제하기
    /// - Parameters:
    ///   - handle : 현재 로그인한 유저의 핸들
    ///   - request : 차단을 해제하고자 하는 사용자의 핸들 (아이디)
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
    
    /// 차단 유저 리스트 조회
    /// - Parameters:
    ///   - handle: 현재 로그인한 유저의 핸들
    ///   - request : page 정보
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러)
    static func getBlockUserList(
        handle: String,
        request: BlockListRequest,
        completion: @escaping (_ succeed: BlockListResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(BlockListAPI.getBlockUserList(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getBlockUserList service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
