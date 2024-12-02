//
//  ProfileDataSingleton.swift
//  pochak
//
//  Created by Seo Cindy on 12/2/24.
//

import CoreFoundation

class ProfileDataSingleton {
    static let shared = ProfileDataSingleton()
    
    var currentTabIndex: Int = 0
    var firstTabHeight: CGFloat = 0.0
    var secondTabHeight: CGFloat = 0.0
    var firstTabIsCurrentlyFetching: Bool = false
    var secondTabIsCurrentlyFetching: Bool = false
    var firstTabIsLastPage: Bool = false
    var secondTabIsLastPage: Bool = false
    
    private init() {}
}
