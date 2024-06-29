//
//  UserDefaultsManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/10/24.
//

import Foundation

class UserDefaultsManager {
    enum UserDefaultsKeys: String, CaseIterable {
        case socialId
        case name
        case email
        case socialType
        case isNewMember
        case handle
        case message
        case profileImgUrl
        case followerCount
        case followingCount
    }
    
    static func setData<T>(value: T, key: UserDefaultsKeys) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }
    
    static func getData<T>(type: T.Type, forKey: UserDefaultsKeys) -> T? {
        let defaults = UserDefaults.standard
        let value = defaults.object(forKey: forKey.rawValue) as? T
        return value
    }
    
    static func removeData(key: UserDefaultsKeys) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key.rawValue)
    }
}
