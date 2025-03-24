//
//  AppStoreUpdateManager.swift
//  pochak
//
//  Created by Suyeon Hwang on 3/16/25.
//

import UIKit

/// 새로운 버전이 배포되었을 때 업데이트 관리
final class AppStoreUpdateManager {
    
    static let shared = AppStoreUpdateManager()
    
    /// 현재 기기에 설치된 앱의 버전
    static let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/6502332418"
    
    /// 현재 앱스토어에 올라가있는 최신 버전 정보을 확인하는 메소드입니다.
    /// - Returns: 최신 버전
    func getLatestVersion() -> String? {
        let appleID = "6502332418"
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appleID)&country=kr"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let appStoreVersion = results[0]["version"] as? String else {
            return nil
        }
        return appStoreVersion
    }
    
    /// AppStore로 이동하는 메소드입니다.
    func openAppStore() {
        guard let url = URL(string: AppStoreUpdateManager.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
