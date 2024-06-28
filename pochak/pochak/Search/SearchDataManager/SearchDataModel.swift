//
//  TagDataModel.swift
//  pochak
//
//  Created by 장나리 on 12/27/23.
//

import Foundation

struct IdSearchData: Codable {
    let profileimgUrl: String
    let userHandle: String
    let memberId: String
}


struct idSearchResponse:Codable{
    let memberId : String
    let profileImage : String
    let handle : String
    let name : String
}
