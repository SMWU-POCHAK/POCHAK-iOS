//
//  ProfileService.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct ProfileService {
    
    /// - Parameters:
    ///   - handle : 조회하는 프로필 유저의 핸들
    ///   - request: page 정보
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func getProfile(
        handle: String,
        request: ProfileRetrievalRequest,
        completion: @escaping (_ succeed: ProfileRetrievalResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(ProfileRetrievalAPI.getProfile(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getProfile error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// - Parameters:
    ///    - handle : 조회하는 프로필 유저의 핸들
    ///    - request: page 정보
    ///    - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func getProfilePochakPosts(
        handle: String,
        request: ProfileRetrievalRequest,
        completion: @escaping (_ succeed: PochakPostRetrievalResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(PochakPostRetrievalAPI.getPochakPost(handle: handle, request: request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getProfilePochakPosts error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// - Parameters:
    ///   - request: 현재 로그인한 유저의 핸들
    ///   - files : 수정한 프로필 이미지
    ///   - request : 수정한 name, message 정보
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func profileUpdate(
        handle: String,
        files: [(Data, String, String)],
        request: ProfileUpdateRequest,
        completion: @escaping (_ succeed: ProfileUpdateResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.uploadMultipart(ProfileUpdateAPI.updateProfile(handle: handle, request: request), files: files) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== profileUpdate error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
