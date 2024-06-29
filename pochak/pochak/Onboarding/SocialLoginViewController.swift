//
//  SocialLoginViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/15.
//

import UIKit
import GoogleSignIn

class SocialLoginViewController: UIViewController {
    
    
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var appleLoginBtn: UIButton!
    @IBOutlet weak var goToJoinBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnLayout()
    }
    
   // MARK: - Button Design
    private func btnLayout(){
        // 소셜 로그인 버튼 디자인
        googleLoginBtn.layer.cornerRadius = 30
        ///테두리 두께 설정해야 함!
        googleLoginBtn.layer.borderWidth = 1
        googleLoginBtn.layer.borderColor = UIColor(named: "gray02")?.cgColor
        appleLoginBtn.layer.cornerRadius = 30
        
        
        // 아직 계정이 없으신가요?
        // String Custom : 이미 계정이 있으신가요?
        if let font = UIFont(name: "Pretendard-Bold", size: 16) {
            let customAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
                .underlineStyle: 1
            ]
            let attributedString = NSAttributedString(string: "아직 계정이 없으신가요?", attributes: customAttributes)
            goToJoinBtn.setAttributedTitle(attributedString, for: .normal)
        } else {return}
        
        // Hide Back Button
        self.navigationItem.setHidesBackButton(true, animated: true)

    }
    
    // MARK: - Google Login
    @IBAction func googleLoginAction(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            // Get User Info
            let user = signInResult.user
            let accessToken = user.accessToken.tokenString
            GoogleLoginDataManager.shared.googleLoginDataManager(accessToken, {resultData in
                guard let isNewMember = resultData.isNewMember else { return }
                guard let name = resultData.name else { return }
                guard let email = resultData.email else { return }
                guard let socialType = resultData.socialType else { return }
                guard let socialId = resultData.id else { return }
                
                // 사용자 기본 데이터 저장
                UserDefaultsManager.setData(value: name, key: .name)
                UserDefaultsManager.setData(value: socialId, key: .socialId)
                UserDefaultsManager.setData(value: email, key: .email)
                UserDefaultsManager.setData(value: socialType, key: .socialType)
                UserDefaultsManager.setData(value: isNewMember, key: .isNewMember)
                print("This is google LOGIN~~~~~~~~~~~")
                print(isNewMember)
                
                self.changeViewControllerAccordingToisNewMemeberState(isNewMember, resultData)
            })
        }
    }
    
    // MARK: - profileSettingPage or HomeTabPage로 전환하기
    private func changeViewControllerAccordingToisNewMemeberState(_ isNewMember : Bool, _ resultData : GoogleLoginModel){
        if isNewMember == true {
            // 알람! : 회원정보가 없습니다 회원가입하시겠습니까?
            let alert = UIAlertController(title:"이런..회원정보가 없어요! 회원가입하시겠습니까?",message: "",preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            let ok = UIAlertAction(title: "확인", style: .default, handler: {
                action in
                self.toMakeProfilePage()
            })
            alert.addAction(cancle)
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        } else if isNewMember == false{
            // 토큰 정보 저장 @KeyChainManager
            guard let accountAccessToken = resultData.accessToken else { return }
            guard let accountRefreshToken = resultData.refreshToken else { return }
            print("Login Again!!!!!")
            print(accountAccessToken)
            print(accountRefreshToken)
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
    
    private func toMakeProfilePage(){
        guard let makeProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeProfileVC") as? MakeProfileViewController else {return}
        self.navigationController?.pushViewController(makeProfileVC, animated: true)
    }
    
    // MARK: - Back Button Action
    // PopVC
    @IBAction func goToJoinBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

}
