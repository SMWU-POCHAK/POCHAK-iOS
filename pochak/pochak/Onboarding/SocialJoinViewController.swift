//
//  SocialLoginViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/13.
//

import UIKit
import GoogleSignIn

class SocialJoinViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        btnLayout()
        
        // MARK: - Navigation Controller Back Button Custom
        // Title
        let attrs : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        
        // Back Button
        /// 주의점 : backBarButtonItem 사용 시 FirstViewController에서 지정!
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var appleLoginBtn: UIButton!
    @IBOutlet weak var goToLoginBtn: UIButton!
    
   // MARK: - Button Design
    private func btnLayout(){
        
        // 소셜 로그인 버튼 디자인
        googleLoginBtn.layer.cornerRadius = 30
        ///테두리 두께 설정해야 함!
        googleLoginBtn.layer.borderWidth = 1
        googleLoginBtn.layer.borderColor = UIColor(named: "gray02")?.cgColor
        appleLoginBtn.layer.cornerRadius = 30
        
        // String Custom : 이미 계정이 있으신가요?
        if let font = UIFont(name: "Pretendard-Bold", size: 16) {
            let customAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
                .underlineStyle: 1
            ]
            let attributedString = NSAttributedString(string: "이미 계정이 있으신가요?", attributes: customAttributes)
            goToLoginBtn.setAttributedTitle(attributedString, for: .normal)
        } else {return}
    }
    
    // MARK: - Button Action
    // to use Push VC has to be in navigation controller : Editor > Embed in > Navigation Controller
    @IBAction func goToLoginBtnTapped(_ sender: UIButton) {
        guard let socialLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "SocialLoginVC") as? SocialLoginViewController else {return}
        self.navigationController?.pushViewController(socialLoginVC, animated: true)
    }
    
    // MARK: - Google Login
    @IBAction func googleLoginAction(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            print(signInResult)
            
            // Get User Info
            let user = signInResult.user
            let accessToken = user.accessToken.tokenString
            GoogleLoginDataManager.shared.googleLoginDataManager(accessToken, {resultData in
                guard let isNewMember = resultData.isNewMember else { return }
                guard let name = resultData.name else {return }
                guard let email = resultData.email else { return }
                guard let socialType = resultData.socialType else { return }
                guard let socialId = resultData.id else { return }
                
                // 사용자 기본 데이터 저장
                UserDefaultsManager.setData(value: socialId, key: .socialId)
                UserDefaultsManager.setData(value: name, key: .name)
                UserDefaultsManager.setData(value: email, key: .email)
                UserDefaultsManager.setData(value: socialType, key: .socialType)
                UserDefaultsManager.setData(value: isNewMember, key: .isNewMember)
                print(isNewMember)
                
                self.changeViewControllerAccordingToisNewMemeberState(isNewMember, resultData)
            })
        }
    }
    
    // MARK: - Apple Login
    
    
    // MARK: - profileSettingPage or HomeTabPage로 전환하기
    private func changeViewControllerAccordingToisNewMemeberState(_ isNewMember : Bool, _ resultData : GoogleLoginModel){
        if isNewMember == true {
            // 프로필 설정 페이지로 이동
            guard let makeProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeProfileVC") as? MakeProfileViewController else {return}
            self.navigationController?.pushViewController(makeProfileVC, animated: true)
        } else {
            // 토큰 정보 저장 @KeyChainManager
            guard let accountAccessToken = resultData.accessToken else { return }
            guard let accountRefreshToken = resultData.refreshToken else { return }
            do {
                try KeychainManager.save(account: "accessToken", value: accountAccessToken, isForce: false)
                try KeychainManager.save(account: "refreshToken", value: accountRefreshToken, isForce: false)
            } catch {
                print(error)
            }
            // 홈탭으로 이동
            toHomeTabPage()
        }
    }
    
    private func toHomeTabPage(){
        guard let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC") as? CustomTabBarController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabbarVC, animated: false)
    }

}
