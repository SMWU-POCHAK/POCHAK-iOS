//
//  PushNotificationService.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/19/24.
//

import Foundation

struct PushNotificationService {
    /// FCM 토큰을 등록합니다.
    /// - Parameters:
    ///   - request: 등록하려는 토큰 값을 가진 PushNotificationRequest
    ///   - completion: 통신 후 핸들러
    static func postFCMToken(
        request: PushNotificationRequest,
        completion: @escaping (_ succeed: PushNotificationResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(TokenRegistrationAPI.postFCMToken(request)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postFCMToken Service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
    }
}
