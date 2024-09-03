//
//  CameraUploadRequest.swift
//  pochak
//
//  Created by 장나리 on 9/2/24.
//

import Foundation

struct CameraUploadRequest:Codable {
    var caption: String
    var taggedMemberHandleList: [String]
}
