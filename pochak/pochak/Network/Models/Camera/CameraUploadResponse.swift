//
//  CameraUploadResponse.swift
//  pochak
//
//  Created by 장나리 on 9/2/24.
//

import Foundation

struct CameraUploadResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
