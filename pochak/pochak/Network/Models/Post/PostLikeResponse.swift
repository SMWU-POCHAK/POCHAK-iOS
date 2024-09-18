//
//  PostLikeResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/9/24.
//

struct PostLikeResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
