//
//  NetworkError.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation

enum NetworkError: Error {
    /** 네트워크에 연결되어 있지 않을 때 에러*/ case disconnected
    /** 클라이언트 에러*/ case clientError // 400
    /** 이미지파일 용량 클때*/ case contentTooLarge // 413
    /** 서버 에러*/ case serverError //500
    /** multipart 에러*/ case multipartError //503
    /** 디코딩 실패  에러*/ case unableToDecode
    /** 알 수 없는 에러*/ case unknownError
}

extension NetworkError {
    var localizedDescription: String {
        switch self {
        case .disconnected: return "네트워크에 연결되어 있지 않습니다."
        case .clientError: return "클라이언트에 문제가 있습니다."
        case .contentTooLarge: return "이미지 파일이 너무 큽니다."
        case .serverError: return "서버에 문제가 있습니다."
        case .multipartError: return "멀티파트 전환 실패했습니다."
        case .unableToDecode: return "디코딩에 실패했습니다."
        case .unknownError: return "알 수 없는 오류입니다."
        }
    }
}
