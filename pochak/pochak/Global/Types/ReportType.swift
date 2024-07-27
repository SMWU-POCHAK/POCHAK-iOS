//
//  ReportType.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/27/24.
//

import Foundation

/// 게시글 신고 종류의 enum
enum ReportType: String {
    case NOT_INTERESTED
    case SPAM
    case NUDITY_OR_SEXUAL_CONTENT
    case FRAUD_OR_SCAM
    case HATE_SPEECH_OR_SYMBOL
    case MISINFORMATION
    
    static let reportReasons = [
        "마음에 들지 않습니다.",
        "스팸",
        "나체 이미지 또는 성적 행위",
        "사기 또는 거짓",
        "혐오 발언 또는 상징",
        "거짓 정보"
    ]
    
    /// 해당 인덱스의 report type 리턴
    static func getReportTypeAt(index: Int) -> ReportType {
        switch index {
        case 0:
            return NOT_INTERESTED
        case 1:
            return SPAM
        case 2:
            return NUDITY_OR_SEXUAL_CONTENT
        case 3:
            return FRAUD_OR_SCAM
        case 4:
            return HATE_SPEECH_OR_SYMBOL
        case 5:
            return MISINFORMATION
        default:
            return NOT_INTERESTED
        }
    }
    
    /// ReportType에 해당하는 사유 string 리턴
    static func getReasonForType(_ reportType: ReportType) -> String {
        switch reportType {
        case .NOT_INTERESTED:
            return reportReasons[0]
        case .SPAM:
            return reportReasons[1]
        case .NUDITY_OR_SEXUAL_CONTENT:
            return reportReasons[2]
        case .FRAUD_OR_SCAM:
            return reportReasons[3]
        case .HATE_SPEECH_OR_SYMBOL:
            return reportReasons[4]
        case .MISINFORMATION:
            return reportReasons[5]
        }
    }
    
    static func getReportTypeCount() -> Int {
        return reportReasons.count
    }
}
