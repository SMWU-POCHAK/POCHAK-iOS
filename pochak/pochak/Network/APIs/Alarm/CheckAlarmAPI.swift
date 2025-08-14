//
//  CheckAlarmAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/14/25.
//

import Foundation
import Alamofire

enum CheckAlarmAPI {
    case postCheckAlarm(alarmId: Int)
}

extension CheckAlarmAPI: BaseAPI {
    typealias Response = CheckAlarmResponse

    var method: HTTPMethod {
        switch self {
        case .postCheckAlarm: return .post
        }
    }

    var path: String {
        switch self {
        case .postCheckAlarm(let alarmId): return "/v2/alarms/\(alarmId)"
        }
    }
}
