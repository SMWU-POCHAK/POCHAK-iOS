//
//  ProfileDataSingleton.swift
//  pochak
//
//  Created by Seo Cindy on 12/2/24.
//

import CoreFoundation
import Foundation

class ProfileDataSingleton {
    static let shared = ProfileDataSingleton()
    
    var currentTabIndex: Int = 0
    var firstTabIsCurrentlyFetching: Bool = false
    var secondTabIsCurrentlyFetching: Bool = false
    var firstTabIsLastPage: Bool = false
    var secondTabIsLastPage: Bool = false
    
    private init() {}
    
    private var _firstTabHeight: CGFloat = 0.0
    private var _secondTabHeight: CGFloat = 0.0
    
    var firstTabHeight: CGFloat {
        get {
            return _firstTabHeight
        }
        set {
            _firstTabHeight = newValue
            NotificationCenter.default.post(name: .didUpdateTotalHeight, object: nil)
        }
    }
    
    var secondTabHeight: CGFloat {
        get {
            return _firstTabHeight
        }
        set {
            _firstTabHeight = newValue
            NotificationCenter.default.post(name: .didUpdateTotalHeight, object: nil)
        }
    }
}
