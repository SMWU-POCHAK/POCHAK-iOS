//
//  HandleDuplicationType.swift
//  pochak
//
//  Created by Seo Cindy on 12/9/24.
//

import Foundation

enum MemberCode: String {
    case success = "MEMBER2001"       // 중복 검사 성공
    case duplicationError = "MEMBER4002" // 중복된 아이디
    case unknown                     // 알 수 없는 코드
    
    init(rawValue: String) {
        switch rawValue {
        case "MEMBER2001":
            self = .success
        case "MEMBER4002":
            self = .duplicationError
        default:
            self = .unknown
        }
    }
}
