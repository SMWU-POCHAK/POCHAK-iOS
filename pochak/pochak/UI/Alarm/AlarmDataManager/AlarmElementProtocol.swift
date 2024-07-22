//
//  AlarmElementProtocol.swift
//  pochak
//
//  Created by 장나리 on 3/6/24.
//

import Foundation

protocol AlarmElementProtocol: Codable {
    var alarmId: Int { get }
    var isChecked: Bool { get }
    // Add common properties here

    // You can add additional properties or methods based on your needs
}

protocol TagApprovalElement: AlarmElementProtocol {
    var tagId: Int { get }
    var ownerHandle: String { get }
    // Add properties specific to TAG_APPROVAL type
}

protocol OwnerCommentElement: AlarmElementProtocol {
    var commentId: Int { get }
    var commentContent: String { get }
    // Add properties specific to OWNER_COMMENT type
}

// Add similar protocols for other alarm types
