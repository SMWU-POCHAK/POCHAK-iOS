//
//  PostDeleteResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

struct PostDeleteResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
