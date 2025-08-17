//
//  CheckAlarmResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/14/25.
//

import Foundation

struct CheckAlarmResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
