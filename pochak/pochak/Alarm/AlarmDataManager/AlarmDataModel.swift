struct AlarmResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: AlarmResult
}

struct AlarmResult: Codable {
    let pageInfo: PageInfo
    let alarmList: [AlarmElementList]
}

struct PageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

enum AlarmType: String, Codable {
    case tagApproval = "TAG_APPROVAL"
    case ownerComment = "OWNER_COMMENT"
    case taggedComment = "TAGGED_COMMENT"
    case commentReply = "COMMENT_REPLY"
    case follow = "FOLLOW"
    case like = "LIKE"
}

struct AlarmElementList: Codable {
    let alarmId: Int
    let alarmType: AlarmType
    let isChecked: Bool
    let tagId: Int?
    let ownerId : Int?
    let ownerHandle: String?
    let ownerName: String?
    let ownerProfileImage: String?
    let postId: Int?
    let postImage: String?
    let memberId : Int?
    let memberHandle: String?
    let memberName: String?
    let memberProfileImage: String?
    let commentId: Int?
    let commentContent: String?
}
