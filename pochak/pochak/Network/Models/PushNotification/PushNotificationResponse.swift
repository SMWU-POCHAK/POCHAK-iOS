//
//  PushNotificationResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/19/24.
//

import Foundation

struct PushNotificationResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
