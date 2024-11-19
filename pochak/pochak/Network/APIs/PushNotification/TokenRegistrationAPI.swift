//
//  TokenRegistrationAPI.swift.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/19/24.
//

import Foundation
import Alamofire

enum TokenRegistrationAPI {
    case postFCMToken(PushNotificationRequest)
}

extension TokenRegistrationAPI: BaseAPI {
    
    typealias Response = PushNotificationResponse
        
    var method: HTTPMethod {
        switch self {
        case .postFCMToken: return .post
        }
    }

    var path: String {
        switch self {
        case .postFCMToken: return "/v1/fcm/register"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .postFCMToken(let request): return .body(request)
        }
    }
}
