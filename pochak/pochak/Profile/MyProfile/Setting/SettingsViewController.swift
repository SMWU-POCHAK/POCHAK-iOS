//
//  SettingsViewController.swift
//  pochak
//
//  Created by Seo Cindy on 5/14/24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var blockManageBtn: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    var selectedBtn : Int = 0
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 커스텀
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "설정"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
    }

    // MARK: - Funtion
    
    @IBAction func moveToTermsOfUsePage(_ sender: Any) {
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
        print("Is New Member: \(isNewMember)")
        print("Handle: \(handle)")
        print("Message: \(message)")
        print("Profile Image URL: \(profileImgUrl)")
        print("Follower Count: \(followerCount)")
        print("Following Count: \(followingCount)")
    }
    
    @IBAction func viewBlockList(_ sender: Any) {
        let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
        BlockedUserListDataManager.shared.blockedUserListDataManager(handle, { resultData in
            // 차단된 계정 페이지로 이동
            guard let blockedUserVC = self.storyboard?.instantiateViewController(withIdentifier: "BlockedUserVC") as? BlockedUserViewController else {return}
            blockedUserVC.blockedUserList = resultData.blockList
            self.navigationController?.pushViewController(blockedUserVC, animated: true)
        })
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
    
    private func toMainPage(){
        // Main.storyboard 가져오기
        let mainVCBundle = UIStoryboard.init(name: "Main", bundle: nil)
        // NavigationController 연결 안되는 문제 -> 해결 : inherit module from target 옵션 체크
        guard let mainVC = mainVCBundle.instantiateViewController(withIdentifier: "NavigationVC") as? NavigationController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
    }
}

// MARK: - Extension

extension SettingsViewController : CustomAlertDelegate {
    
    func confirmAction() {
        if selectedBtn == 0 {
            // API 호출
            LogoutDataManager.shared.logoutDataManager(
                { resultData in
                let message = resultData.message
                print(message)
            })
            
            // Keychain Delete
            do {
                try KeychainManager.delete(account: "accessToken")
                try KeychainManager.delete(account: "refreshToken")
            } catch {
                print(error)
            }
            
            // UserDefulats Delete
            // enum -> CaseIterable 설정해두면 allCases로 내부요소 접근 가능
            // handle 제외 전부 삭제
            UserDefaultsManager.UserDefaultsKeys.allCases.forEach { key in
                if("\(key)" == "handle"){
                }else{
                    UserDefaultsManager.removeData(key: key)
                }
            }
            
            // Main으로 화면 전환
            self.toMainPage()
            
        } else if selectedBtn == 1 {
            // API 호출
            SignOutDataManager.shared.signOutDataManager(
                { resultData in
                let message = resultData.message
                print(message)
            })
            
            // Keychain Delete
            do {
                try KeychainManager.delete(account: "accessToken")
                try KeychainManager.delete(account: "refreshToken")
            } catch {
                print(error)
            }
            
            // UserDefulats Delete
            UserDefaultsManager.UserDefaultsKeys.allCases.forEach { key in
                UserDefaultsManager.removeData(key: key)
            }
            
            // Main으로 화면 전환
            self.toMainPage()
        }
    }
    
    func cancel() {
        print("cancel button selected")
    }
}
