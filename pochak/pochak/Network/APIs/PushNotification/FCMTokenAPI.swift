//
//  TokenRegistrationAPI.swift.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/19/24.
//

import Foundation
import Alamofire

enum FCMTokenAPI {
    case postFCMToken(PushNotificationRequest)
    case deleteFCMToken
}

extension FCMTokenAPI: BaseAPI {
    
    typealias Response = PushNotificationResponse
        
    var method: HTTPMethod {
        switch self {
        case .postFCMToken: return .post
        case .deleteFCMToken: return .delete
        }
    }

    var path: String {
        switch self {
        case .postFCMToken: return "/v1/fcm/register"
        case .deleteFCMToken: return "/v1/fcm"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .postFCMToken(let request): return .body(request)
        case .deleteFCMToken: return nil
        }
    }
}
