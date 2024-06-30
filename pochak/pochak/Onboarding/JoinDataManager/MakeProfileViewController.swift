//
//  MakeProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/14.
//

import UIKit

class MakeProfileViewController: UIViewController {
        
    // MARK: - Data
    
    let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
    let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    let socialType = UserDefaultsManager.getData(type: String.self, forKey: .socialType) ?? "socialType not found"
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"

    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 완료 버튼 커스텀
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(named: "yellow00"), for: .normal)
        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 16)
        button.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        // 네비게이션바 title 커스텀
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "프로필 설정"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        // 네비게이션바 Back 버튼 커스텀
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        // Name 항목 채워넣기
        nameTextField.text = name
        
        // 프로필 image 레이아웃
        profileImg.imageView?.contentMode = .scaleAspectFill
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = 58
    }

    // MARK: - Function
    
    @objc private func doneBtnTapped(_ sender: Any) {
        
        // 새로운 유저 정보 UserDefaults에 저장 : name / handle / message
        guard let name = nameTextField.text  else {return}
        guard let handle = handleTextField.text  else {return}
        guard let message = messageTextField.text  else {return}
        guard let profileImage = profileImg.currentImage  else {return}
        
        UserDefaultsManager.setData(value: name, key: .name)
        UserDefaultsManager.setData(value: handle, key: .handle)
        UserDefaultsManager.setData(value: message, key: .message)
        
        // API request : POST
        JoinDataManager.shared.joinDataManager(name,
                                               email,
                                               handle,
                                               message,
                                               socialId,
                                               socialType,
                                               profileImage,
                                               {resultData in
            
            print("JoinDataManager resultData : \(resultData)")
            
            // 새로운 유저 정보 UserDefaults에 저장 : IsNewMember
            UserDefaultsManager.setData(value: resultData.isNewMember, key: .isNewMember)
            
            
            // 유저 토큰 정보 저장 @KeyChainManager
            guard let accountAccessToken = resultData.accessToken else { return }
            guard let accountRefreshToken = resultData.refreshToken else { return }
            print("JoinDataManager accountAccessToken = \(accountAccessToken)")
            print("JoinDataManager accountRefreshToken = \(accountRefreshToken)")
            
            do {
                try KeychainManager.save(account: "accessToken", value: accountAccessToken, isForce: true)
                try KeychainManager.save(account: "refreshToken", value: accountRefreshToken, isForce: true)
            } catch {
                print(error)
            }
        })
        
        // 홈 화면으로  전환
        toHomeTabPage()
    }
    
    // 프로필 사진 설정
    /*
    1. 권한 설정 : Info.plist > Photo Library Usage 권한 추가
    2. UIImagePickerController 선언
    3. @IBAction 정의
    4. 프로토콜 채택
     */
    let imagePickerController = UIImagePickerController()
    @IBAction func profileBtnTapped(_ sender: Any) {
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
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

// MARK: - Extension

// 앨범 사진 선택 프로토콜 채택
extension MakeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 선택한 사진 사용
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImg.setImage(image, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil) // 주의점 : picker 숨기기 위한 dismiss를 직접 해야함
    }
    
    // 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
