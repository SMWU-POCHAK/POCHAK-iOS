//
//  LikedUsersDataResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/10/23.
//

// MARK: - 좋아요 누른 사람 조회
struct LikedUsersDataResponse: Codable {
    let isSuccess: Bool?
    let code: String
    let message: String?
    let result: LikedUserDataResult
}

struct LikedUserDataResult: Codable {
    let likeMembersList: [LikeMember]
}

struct LikeMember: Codable {
    let handle: String?
    let profileImage: String?
    let name: String?
    let follow: Bool?  // 팔로우 여부, 자기 자신일 경우 null 값 반환 아마도.....
}

// MARK: - 좋아요 누르기
struct LikePostDataResponse: Codable {
    let isSuccess: Bool?
    let code: String
    let message: String?
}
