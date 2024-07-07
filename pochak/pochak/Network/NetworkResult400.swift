//
//  ErrorDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 7/6/24.
//

enum NetworkResult400<T>{
    case success(T) // 서버 통신 성공
    case MEMBER4002 // 유효하지 않은 멤버의 handle인 경우
}
