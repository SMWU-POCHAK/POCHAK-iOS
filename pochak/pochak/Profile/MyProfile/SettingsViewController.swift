//
//  SettingsViewController.swift
//  pochak
//
//  Created by Seo Cindy on 5/14/24.
//

import UIKit

class SettingsViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 세팅
        /// Title
        self.navigationItem.title = "설정"
        /// Back Button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
    }

    
    @IBAction func moveToTermsOfUsePage(_ sender: Any) {
        print("------- moveToTermsOfUsePage clicked -------")
        guard let termsOfUseVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUseVC") as? TermsOfUseViewController else {return}
        self.navigationController?.pushViewController(termsOfUseVC, animated: true)
    }
    
    @IBAction func logOut(_ sender: Any) {
        // 알람! : 회원정보가 없습니다 회원가입하시겠습니까?
        let alert = UIAlertController(title:"로그아웃 하시겠습니까?",message: "",preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {
            action in
            // API
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
            UserDefaultsManager.UserDefaultsKeys.allCases.forEach { key in
                if("\(key)" == "handle"){
                    // forEach는 반복문이 아니기 때문에 break 혹은 continue 사용 불가
                    return
                }else{
                    UserDefaultsManager.removeData(key: key)
                }
            }
            // Main으로 화면 전환
            self.toMainPage()
        })
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteAccount(_ sender: Any) {
        // 알람! : 회원정보가 없습니다 회원가입하시겠습니까?
        let alert = UIAlertController(title:"회원 탈퇴하시겠습니까?",message: "회원탈퇴 시, 개인정보 및 기존에 업로드된 피드 정보가 모두 사라집니다.",preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        let ok = UIAlertAction(title: "탈퇴하기", style: .default, handler: {
            action in
            // API
            DeleteAccountDataManager.shared.deleteAccountDataManager(
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
            self.toMainPage()
        })
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    // 회원가입 페이지로 이동
    private func toMainPage(){
        // Main.storyboard 가져오기
        let mainVCBundle = UIStoryboard.init(name: "Main", bundle: nil)
        // NavigationController 연결 안되는 문제 -> 해결 : inherit module from target 옵션 체크
        guard let mainVC = mainVCBundle.instantiateViewController(withIdentifier: "NavigationVC") as? NavigationController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
    }

}
