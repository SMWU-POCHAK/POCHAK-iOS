//
//  SocialLoginViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/13.
//

import UIKit
import GoogleSignIn

class SocialJoinViewController: UIViewController {
    
    // MARK: - Data
    
    @IBOutlet weak var startPochak: UILabel!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var appleLoginBtn: UIButton!
    @IBOutlet weak var goToLoginBtn: UIButton!
    
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
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // 로그인 버튼 디자인 커스텀
        btnLayout()
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
            GoogleLoginDataManager.shared.googleLoginDataManager(accessToken, {resultData in
                
                // 사용자 기본 데이터 저장 : id / name / email / socialType / isNewMember
                guard let socialId = resultData.id else { return }
                guard let name = resultData.name else {return }
                guard let email = resultData.email else { return }
                guard let socialType = resultData.socialType else { return }
                guard let isNewMember = resultData.isNewMember else { return }
                
                UserDefaultsManager.setData(value: socialId, key: .socialId)
                UserDefaultsManager.setData(value: name, key: .name)
                UserDefaultsManager.setData(value: email, key: .email)
                UserDefaultsManager.setData(value: socialType, key: .socialType)
                
                self.changeViewControllerAccordingToisNewMemeberState(isNewMember, resultData)
            })
        }
    }
    
    // MARK: - Apple Login
    
    // MARK: - Function
    
    private func btnLayout(){
        googleLoginBtn.layer.cornerRadius = 30
        googleLoginBtn.layer.borderWidth = 1
        googleLoginBtn.layer.borderColor = UIColor(named: "gray02")?.cgColor
        appleLoginBtn.layer.cornerRadius = 30
        
        // "이미 계정이 있으신가요?" 커스텀
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
    
    @IBAction func goToLoginBtnTapped(_ sender: UIButton) {
        // "이미 계정이 있으신가요?" 없어지도록
        let aa = NSAttributedString(string: "")
        goToLoginBtn.setAttributedTitle(aa, for: .normal)
        
        // 포착 시작하기 -> 로그인하기로 변경
        startPochak.text = "로그인하기"
    }
    
    private func changeViewControllerAccordingToisNewMemeberState(_ isNewMember : Bool, _ resultData : GoogleLoginModel){
        if isNewMember == true {
            // 프로필 설정 페이지로 이동
            guard let makeProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeProfileVC") as? MakeProfileViewController else {return}
            self.navigationController?.pushViewController(makeProfileVC, animated: true)
        } else {
            // 이미 회원인 유저의 경우 토큰 정보 저장 @KeyChainManager
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
        let homeTabViewController = UIStoryboard(name: "HomeTab", bundle: nil).instantiateViewController(withIdentifier: "HomeTabViewController")
        let postTabViewController = UIStoryboard(name: "PostTab", bundle: nil).instantiateViewController(withIdentifier: "PostTabViewController")
        let cameraTabViewController = UIStoryboard(name: "CameraTab", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController")
        let alarmTabViewController = UIStoryboard(name: "AlarmTab", bundle: nil).instantiateViewController(withIdentifier: "AlarmViewController")
        let myProfileViewController = UIStoryboard(name: "ProfileTab", bundle: nil).instantiateViewController(withIdentifier: "MyProfileTabVC")
        
        let homeNavController = UINavigationController(rootViewController: homeTabViewController)
        let postNavController = UINavigationController(rootViewController: postTabViewController)
        let cameraNavController = UINavigationController(rootViewController: cameraTabViewController)
        let alarmNavController = UINavigationController(rootViewController: alarmTabViewController)
        let myProfileNavController = UINavigationController(rootViewController: myProfileViewController)
        
        let tabBarController = CustomTabBarController()
        tabBarController.setViewControllers([homeNavController, postNavController, cameraNavController, alarmNavController, myProfileNavController], animated: false)
        
        if let items = tabBarController.tabBar.items {
            items[0].selectedImage = UIImage(named: "home_logo_fill")?.withRenderingMode(.alwaysOriginal)
            items[0].image = UIImage(named: "home_logo")?.withRenderingMode(.alwaysOriginal)
            items[0].title = "홈"
            
            items[1].selectedImage = UIImage(named:"post_fill")?.withRenderingMode(.alwaysOriginal)
            items[1].image = UIImage(named:"post")?.withRenderingMode(.alwaysOriginal)
            items[1].title = "게시글"
            
            items[2].selectedImage = UIImage(named:"pochak_fill")?.withRenderingMode(.alwaysOriginal)
            items[2].image = UIImage(named:"pochak")?.withRenderingMode(.alwaysOriginal)
            items[2].title = "카메라"
            
            items[3].selectedImage = UIImage(named:"alarm_fill")?.withRenderingMode(.alwaysOriginal)
            items[3].image = UIImage(named:"alarm")?.withRenderingMode(.alwaysOriginal)
            items[3].title = "알림"
            
            items[4].selectedImage = UIImage(named:"profile_fill")?.withRenderingMode(.alwaysOriginal)
            items[4].image = UIImage(named:"profile")?.withRenderingMode(.alwaysOriginal)
            items[4].title = "프로필"
        }
        
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        guard let delegate = sceneDelegate else {
            return
        }
        delegate.window?.rootViewController = tabBarController
    }
}
