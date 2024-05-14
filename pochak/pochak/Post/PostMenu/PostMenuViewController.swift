//
//  PostMenuViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/12/24.
//

import UIKit

class PostMenuViewController: UIViewController {
    
    // MARK: - Views

    @IBOutlet weak var menuTableView: UITableView!
    private var currentUserIsOwner = false
    
    // MARK: - Properties
    
    private var postId: Int?
    private var postOwner: String?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("게시글 추가 메뉴 \(postId)")
        
        // 게시물 작성자와 현재 로그인된 유저가 같으면 삭제 메뉴 추가
        // TODO: 로그인 구현 후 수정
        if(postOwner == APIConstants.dayeonHandle){
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
    
    func setPostIdAndOwner(postId: Int, postOwner: String){
        self.postId = postId
        self.postOwner = postOwner
    }
    
    private func setupTableView(){
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        menuTableView.register(UINib(nibName: "ReportViewCell", bundle: nil), forCellReuseIdentifier: "ReportViewCell")
        menuTableView.register(UINib(nibName: "DeleteViewCell", bundle: nil), forCellReuseIdentifier: "DeleteViewCell")
        menuTableView.register(UINib(nibName: "CancelViewCell", bundle: nil), forCellReuseIdentifier: "CancelViewCell")
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
            cell = (tableView.dequeueReusableCell(withIdentifier: "ReportViewCell", for: indexPath) as?                        ReportViewCell) ?? UITableViewCell()
        }
        else if indexPath.row == 1 {
            if currentUserIsOwner {
                cell = tableView.dequeueReusableCell(withIdentifier: "DeleteViewCell", for: indexPath) as?                        DeleteViewCell ?? UITableViewCell()
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "CancelViewCell", for: indexPath) as?                        CancelViewCell ?? UITableViewCell()
            }
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CancelViewCell", for: indexPath) as?                        CancelViewCell ?? UITableViewCell()
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
            print(parentVC)
            // postMenuVC를 dismiss 후 pvc에서 present
            dismiss(animated: true) {
                parentVC.present(reportVC, animated: true)
            }
            print("신고하기")
        }
        else if tableView.numberOfRows(inSection: 0) == 3 && indexPath.row == 1 {
            print("삭제하기")
        }
        else {
            dismiss(animated: true)
            print("취소하기")
        }
    }
    
}
