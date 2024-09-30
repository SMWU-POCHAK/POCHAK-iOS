//
//  SocialLoginViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/13.
//

import UIKit
import GoogleSignIn
import AuthenticationServices // 애플 로그인

protocol SendDelegate {
    func sendAgreed(agree : Bool)
}

class SocialJoinViewController: UIViewController, SendDelegate {
    func sendAgreed(agree: Bool) {
        if agree {
            guard let makeProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeProfileVC") as? MakeProfileViewController else {return}
            self.navigationController?.pushViewController(makeProfileVC, animated: true)
        } else {
            print("not agreed yet!")
        }
    }
    
    
    // MARK: - Data
    
    @IBOutlet weak var startPochak: UILabel!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var appleLoginBtn: UIButton!
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title
        //        let attrs : [NSAttributedString.Key : Any] = [
        //            NSAttributedString.Key.foregroundColor: UIColor.black,
        //            NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 20)!
        ////        ]
        //
        //        UINavigationBar.appearance().titleTextAttributes = attrs
        //        self.navigationController?.navigationBar.titleTextAttributes = attrs
        
        // 네비게이션 바 Back Button 커스텀
        /// 주의점 : backBarButtonItem 사용 시 FirstViewController에서 지정!
//        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
//        backBarButtonItem.tintColor = .black
//        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // 로그인 버튼 디자인 커스텀
        btnLayout()
    }
    override func viewWillAppear(_ animated: Bool){
        // 뷰가 나타날 때에는 네비게이션 바 숨기기
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 뷰가 사라질 때에는 네비게이션 바 다시 보여주기
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Google Login
    
    @IBAction func googleLoginAction(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            // Get User Info
            let user = signInResult.user
            let accessToken = user.accessToken.tokenString
            print("googleLogin 시스템 안의 accessToken : \(accessToken)")
            
            // 로딩모달
            self.showProgressBar()

            GoogleLoginDataManager.shared.googleLoginDataManager(accessToken, {resultData in
                
                print("GoogleLoginDataManager 안의 resultData : \(resultData)")
                // 사용자 기본 데이터 저장 : socialId / email / socialType
                UserDefaultsManager.setData(value: resultData.socialId, key: .socialId)
                UserDefaultsManager.setData(value: resultData.email, key: .email)
                UserDefaultsManager.setData(value: resultData.socialType, key: .socialType)
                
                guard let isNewMember = resultData.isNewMember else { return }
                self.changeViewControllerAccordingToisNewMemeberStateForGoogle(isNewMember, resultData)
                
                // 로딩 숨김
                self.hideProgressBar()
            })
        }
    }
    
    // MARK: - Apple Login
    
    @IBAction func appleLoginAction(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] //유저로 부터 알 수 있는 정보들(name, email)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Function
    
    private func btnLayout(){
        googleLoginBtn.layer.cornerRadius = 30
        googleLoginBtn.layer.borderWidth = 1
        googleLoginBtn.layer.borderColor = UIColor(named: "gray02")?.cgColor
        appleLoginBtn.layer.cornerRadius = 30
    }
    
    private func changeViewControllerAccordingToisNewMemeberStateForGoogle(_ isNewMember : Bool, _ resultDataForGoogle : GoogleLoginModel){
        if isNewMember == true {
            guard let termsOfAgreeVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfAgreeVC") as? TermsOfAgreeViewController else {return}
            termsOfAgreeVC.modalPresentationStyle = .overCurrentContext    //  투명도가 있으면 투명도에 맞춰서 나오게 해주는 코드(뒤에있는 배경이 보일 수 있게)
            termsOfAgreeVC.delegate = self
            self.present(termsOfAgreeVC, animated: false, completion: nil)
        } else {
            // 이미 회원인 유저의 경우 토큰 정보 저장 @KeyChainManager
            guard let accountAccessToken = resultDataForGoogle.accessToken else { return }
            guard let accountRefreshToken = resultDataForGoogle.refreshToken else { return }
            do {
                try KeychainManager.save(account: "accessToken", value: accountAccessToken, isForce: false)
                try KeychainManager.save(account: "refreshToken", value: accountRefreshToken, isForce: false)
            } catch {
                print(error)
            }
            
            UserDefaultsManager.setData(value: resultDataForGoogle.handle, key: .handle)
            // 홈탭으로 이동
            toHomeTabPage()
        }
    }
    
    private func changeViewControllerAccordingToisNewMemeberStateForApple(_ isNewMember : Bool, _ resultDataForApple : AppleLoginModel){
        if isNewMember == true {
            print("inside changeVCForApple")
            // 프로필 설정 페이지로 이동
            guard let termsOfAgreeVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfAgreeVC") as? TermsOfAgreeViewController else {return}
            termsOfAgreeVC.modalPresentationStyle = .overCurrentContext    //  투명도가 있으면 투명도에 맞춰서 나오게 해주는 코드(뒤에있는 배경이 보일 수 있게)
            termsOfAgreeVC.delegate = self
            self.present(termsOfAgreeVC, animated: false, completion: nil)
        } else {
            // 이미 회원인 유저의 경우 토큰 정보 저장 @KeyChainManager
            guard let accountAccessToken = resultDataForApple.accessToken else { return }
            guard let accountRefreshToken = resultDataForApple.refreshToken else { return }
            do {
                try KeychainManager.save(account: "accessToken", value: accountAccessToken, isForce: false)
                try KeychainManager.save(account: "refreshToken", value: accountRefreshToken, isForce: false)
            } catch {
                print(error)
            }
            UserDefaultsManager.setData(value: resultDataForApple.handle, key: .handle)
            // 홈탭으로 이동
            toHomeTabPage()
        }
    }
    
    private func toHomeTabPage(){
        
        let tabBarController = CustomTabBarController()
        
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        guard let delegate = sceneDelegate else {
            return
        }
        delegate.window?.rootViewController = tabBarController
    }
}

// MARK: - Apple Login Extension
extension SocialJoinViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //로그인 성공
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // You can create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
                
                // 로딩모달
                self.showProgressBar()
                
                // API request : POST
                AppleLoginDataManager.shared.appleLoginDataManager(identifyTokenString, authCodeString, {resultData in
                    
                    // 사용자 기본 데이터 저장 : id / email / socialType / isNewMember
                    UserDefaultsManager.setData(value: resultData.socialId, key: .socialId)
                    UserDefaultsManager.setData(value: resultData.email, key: .email)
                    UserDefaultsManager.setData(value: resultData.socialType, key: .socialType)
                    UserDefaultsManager.setData(value: resultData.refreshToken, key: .socialRefreshToken)
                    
                    guard let isNewMember = resultData.isNewMember else { return }
                    self.changeViewControllerAccordingToisNewMemeberStateForApple(isNewMember, resultData)
                    // 로딩 숨김
                    self.hideProgressBar()
                })
                
            }
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(username)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 실패(유저의 취소도 포함)
        print("login failed - \(error.localizedDescription)")
    }
}
