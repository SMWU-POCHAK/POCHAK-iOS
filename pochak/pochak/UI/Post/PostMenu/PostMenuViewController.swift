//
//  PostMenuViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/12/24.
//

import UIKit

class PostMenuViewController: UIViewController {
    
    // MARK: - Properties
    
    private var postId: Int?
    private var postOwner: String?
    private var currentUserIsOwner = false
    private var postDeleteResponse: PostDeleteResponse?
    
    // MARK: - Views

    @IBOutlet weak var menuTableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("게시글 추가 메뉴 \(postId)")
        
        // 게시물 작성자와 현재 로그인된 유저가 같으면 삭제 메뉴 추가
        if(postOwner == UserDefaultsManager.getData(type: String.self, forKey: .handle)) {
            currentUserIsOwner = true
        }
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = menuTableView.indexPathForSelectedRow {
            menuTableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    // MARK: - Functions
    
    func setPostIdAndOwner(postId: Int, postOwner: String) {
        self.postId = postId
        self.postOwner = postOwner
    }
    
    private func setupTableView() {
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        menuTableView.register(UINib(nibName: ReportViewCell.identifier, bundle: nil), forCellReuseIdentifier: ReportViewCell.identifier)
        menuTableView.register(UINib(nibName: DeleteViewCell.identifier, bundle: nil), forCellReuseIdentifier: DeleteViewCell.identifier)
        menuTableView.register(UINib(nibName: CancelViewCell.identifier, bundle: nil), forCellReuseIdentifier: CancelViewCell.identifier)
    }
    
    /// 게시글 삭제 혹은 신고 후 홈으로 돌아가기
    private func goBackToHome() {
        // 1. postMenuVC를 보여주고 있는 뷰컨트롤러를 찾고 (=tabbar controller)
        if let tabBarController = self.presentingViewController as? UITabBarController,
           // 2. 선택된 뷰컨트롤러에 접근 (=navigation controller)
           let navigationController = tabBarController.selectedViewController as? UINavigationController {
            // 3. 부모의 부모 뷰컨트롤러 (= home tab view controller)에 접근
            if let grandparentViewController = navigationController.viewControllers.dropLast().last {
//                // 홈탭에서 게시글 상세로 이동한 경우
//                if let vc = grandparentViewController as? HomeTabViewController{
//                    
//                }
//                // TODO: - 나리 -> 여기에 탐색 탭에서 게시글 다시 불러오는 코드 추가해주기!
//                else if let vc = grandparentViewController as? PostTabViewController {
//                    
//                }
//                // TODO: - 정연 -> 여기에 프로필에서 게시글 다시 불러오는 코드 추가해주기! (내 프로필, 남의 프로필 둘 다 해야 할듯??)
//                else if let vc = grandparentViewController as? MyProfileTabViewController {
//                    
//                }
                // 모달을 해제하고 그 후 네비게이션 스택에서 원하는 뷰컨트롤러로 이동
                self.dismiss(animated: true) {
                    navigationController.popToViewController(grandparentViewController, animated: true)
                }
            }
        }
    }
}

// MARK: - Extension: UITableView

extension PostMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 현재 유저가 게시물 작성자이면 삭제하기 메뉴를 포함해야 하므로 3, 아니면 삭제하기 메뉴가 없어야 하므로 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUserIsOwner ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        // 로직 처리가 좀 이상한듯 한데..;;;
        if indexPath.row == 0 {
            cell = (tableView.dequeueReusableCell(withIdentifier: ReportViewCell.identifier, for: indexPath) as?                        ReportViewCell) ?? UITableViewCell()
        }
        else if indexPath.row == 1 {
            if currentUserIsOwner {
                cell = tableView.dequeueReusableCell(withIdentifier: DeleteViewCell.identifier, for: indexPath) as?                        DeleteViewCell ?? UITableViewCell()
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: CancelViewCell.identifier, for: indexPath) as?                        CancelViewCell ?? UITableViewCell()
            }
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: CancelViewCell.identifier, for: indexPath) as?                        CancelViewCell ?? UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "PostTab", bundle: nil)
            let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportVC") as! ReportViewController
            reportVC.setPostId(postId!)  // 신고하는 게시물 아이디 넘겨주기
            
            let sheet = reportVC.sheetPresentationController
 
            sheet?.detents = [.medium(), .large()]
            sheet?.prefersGrabberVisible = true
            
            // postMenuVC를 보여주고 있는 뷰컨트롤러를 찾고
            guard let parentVC = presentingViewController else { return }
            // postMenuVC를 dismiss 후 pvc에서 present
            dismiss(animated: true) {
                parentVC.present(reportVC, animated: true)
            }
        }
        else if tableView.numberOfRows(inSection: 0) == 3 && indexPath.row == 1 {
            showAlert(alertType: .confirmAndCancel,
                      titleText: "게시물을 삭제하시겠습니까?",
                      messageText: "게시물 삭제 시, 복구가 어렵습니다.\n그래도 하시겠습니까?",
                      cancelButtonText: "취소",
                      confirmButtonText: "삭제하기"
            )
        }
        else {
            dismiss(animated: true)
        }
    }
}

// MARK: - Extension: CustomAlertDelegate

extension PostMenuViewController: CustomAlertDelegate {
    
    func confirmAction() {
        PostDataService.shared.deletePost(postId!) { [weak self] response in
            switch(response){
            case .success(let postDeleteResponse):
                self?.postDeleteResponse = postDeleteResponse as? PostDeleteResponse
                if self?.postDeleteResponse?.isSuccess == false {
                    let alert = UIAlertController(title: "게시글 삭제에 실패하였습니다.", message: "다시 시도해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                        self?.dismiss(animated: true)
                    }))
                    return
                }
                else {
                    self?.goBackToHome()
                }
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
                self?.present(UIAlertController.networkErrorAlert(title: "서버에 문제가 있습니다."), animated: true)
            case .networkFail:
                print("networkFail")
                self?.present(UIAlertController.networkErrorAlert(title: "네트워크 연결에 문제가 있습니다."), animated: true)
            }
        }
    }
    
    func cancel() {
        
    }
}
