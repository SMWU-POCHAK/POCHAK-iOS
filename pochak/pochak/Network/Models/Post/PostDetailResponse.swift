//
//  PostDetailResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

struct PostDetailResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PostDetailResponseResult
}

struct PostDetailResponseResult: Codable {
    let ownerHandle: String
    let ownerProfileImage: String
    let tagList: [TaggedMember]
    let isFollow: Bool?  // 현재 로그인한 유저가 게시자라면 null이 됨
    let postImage: String
    let isLike: Bool
    let likeCount: Int
    let caption: String
    let recentComment: RecentComment?
}

struct TaggedMember: Codable {
    let memberId: Int
    let profileImage: String
    let handle: String
    let name: String
}

struct RecentComment: Codable {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
}
