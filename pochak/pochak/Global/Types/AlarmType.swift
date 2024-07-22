//
//  AlarmType.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/22/24.
//

enum AlarmType: String, Codable {
    case tagApproval = "TAG_APPROVAL"
    case ownerComment = "OWNER_COMMENT"
    case taggedComment = "TAGGED_COMMENT"
    case commentReply = "COMMENT_REPLY"
    case follow = "FOLLOW"
    case ownerLike = "OWNER_LIKE"
    case taggedLike = "TAGGED_LIKE"
}
