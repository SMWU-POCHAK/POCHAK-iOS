//
//  SettingsViewController.swift
//  pochak
//
//  Created by Seo Cindy on 5/14/24.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    var selectedBtn: Int = 0
    var realmManager = RecentSearchRealmManager()
    
    // MARK: - Views
    
    @IBOutlet weak var blockManageBtn: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    // MARK: - Actions
    
    @IBAction func openTermsOfUse(_ sender: Any) {
        // 배포 시 삭제(로그 확인 용)
        printUserData()
        
        guard let url = URL(string: "https://pochak.notion.site/6520996186464c36a8b3a04bc17fa000?pvs=74") else { return }
        let safariVC = SFSafariViewController(url: url)
        /// delegate 지정 및 presentation style 설정
        safariVC.transitioningDelegate = self
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true, completion: nil)

    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        guard let url = URL(string: "https://pochak.notion.site/e365e34f018949b88543adbe6b0b3746") else { return }
        let safariVC = SFSafariViewController(url: url)
        /// delegate 지정 및 presentation style 설정
        safariVC.transitioningDelegate = self
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func viewBlockList(_ sender: Any) {
        guard let blockedUserVC = self.storyboard?.instantiateViewController(withIdentifier: "BlockedUserVC") as? BlockedUserViewController else {return}
        self.navigationController?.pushViewController(blockedUserVC, animated: true)
    }
    
    @IBAction func logOut(_ sender: Any) {
        selectedBtn = 0
        showAlert(alertType: .confirmAndCancel,
                  titleText: "로그아웃 하시겠습니까?",
                  messageText: "",
                  cancelButtonText: "취소",
                  confirmButtonText: "확인"
        )
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        selectedBtn = 1
        showAlert(alertType: .confirmAndCancel,
                  titleText: "회원탈퇴하시겠습니까?",
                  messageText: "회원 탈퇴 시, 개인정보 및 기존에 업로드된 \n피드 정보가 모두 사라집니다.",
                  cancelButtonText: "취소",
                  confirmButtonText: "탈퇴하기"
        )
    }
    
    // MARK: - Functions
    
    private func setUpNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "설정"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
    }
    
    private func moveToMainPage() {
        let mainVCBundle = UIStoryboard.init(name: "Login", bundle: nil)
        guard let mainVC = mainVCBundle.instantiateViewController(withIdentifier: "NavigationVC") as? NavigationController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
    }
    
    private func deleteUserData() {
        do {
            // Keychain 삭제
            try KeychainManager.delete(account: "accessToken")
            try KeychainManager.delete(account: "refreshToken")
            
            // 최근 검색 기록 삭제
            if realmManager.deleteAllData() {
                print("Successfully deleted all data")
            } else {
                print("Failed to delete all data")
            }
            
            // UserDefaults 삭제
            UserDefaultsManager.UserDefaultsKeys.allCases.forEach { key in
                UserDefaultsManager.removeData(key: key)
            }
        } catch {
            print(error)
        }
    }
    
    private func printUserData() {
        // 현재 저장된 모든 Keycahin : accessToken, refreshToken
        let accessToken = GetToken.getAccessToken()
        let refreshToken = GetToken.getRefreshToken()
        
        // 현재 저장된 모든 userdefaults
        let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
        let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
        let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
        let socialType = UserDefaultsManager.getData(type: String.self, forKey: .socialType) ?? "socialType not found"
        let isNewMember = UserDefaultsManager.getData(type: Bool.self, forKey: .isNewMember)
        let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
        let message = UserDefaultsManager.getData(type: String.self, forKey: .message) ?? "message not found"
        let profileImgUrl = UserDefaultsManager.getData(type: String.self, forKey: .profileImgUrl) ?? "profileImgUrl not found"
        let followerCount = UserDefaultsManager.getData(type: Int.self, forKey: .followerCount) ?? -1
        let followingCount = UserDefaultsManager.getData(type: Int.self, forKey: .followingCount) ?? -1
        
        // Print values
        print("Access Token: \(accessToken)")
        print("Refresh Token: \(refreshToken)")
        print("--- User Defaults Values ---")
        print("Social ID: \(socialId)")
        print("Name: \(name)")
        print("Email: \(email)")
        print("Social Type: \(socialType)")
        print("Is New Member: \(String(describing: isNewMember))")
        print("Handle: \(handle)")
        print("Message: \(message)")
        print("Profile Image URL: \(profileImgUrl)")
        print("Follower Count: \(followerCount)")
        print("Following Count: \(followingCount)")
    }
}

// MARK: - Extension : CustomAlertDelegate, UIViewControllerTransitioningDelegate

extension SettingsViewController: CustomAlertDelegate {
    
    func confirmAction() {
        if selectedBtn == 0 {
            LogoutDataManager.shared.logoutDataManager(
                { resultData in
                    let message = resultData.message
                    print(message)
                })
            
            deleteUserData()
            moveToMainPage()
            
        } else if selectedBtn == 1 {
            SignOutDataManager.shared.signOutDataManager(
                { resultData in
                    let message = resultData.message
                    print(message)
                })
            
            deleteUserData()
            moveToMainPage()
        }
    }
    
    func cancel() {
        print("cancel button selected")
    }
}

extension SettingsViewController: UIViewControllerTransitioningDelegate {}
