//
//  ReportViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

final class ReportViewController: UIViewController {
    
    // MARK: - Properties

    private var postId: Int?
    private let viewModel = PostDetailViewModel()

    // MARK: - Views
    
    @IBOutlet weak var reportTableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bind()
        setTableView()
    }
    
    // MARK: - Functions
    
    private func bind() {
        viewModel.reportPostResponseDataDidChange = { [weak self] data in
            guard let data = data else { return }
            print("=== Report vc, report cell selected succeeded ===")
            print("== data: \(data)")
            
            if data.isSuccess == true {
                self?.showAlert(alertType: .confirmOnly,
                                titleText: "신고가 완료되었습니다.",
                                messageText: "신고해주셔서 감사합니다.\n빠른 시일 내에 해결하겠습니다.",
                                confirmButtonText: "확인")
            }
            else {
                self?.present(UIAlertController.networkErrorAlert(title: "게시글 신고에 실패하였습니다."), animated: true)
            }
        }
    }
    
    private func setTableView() {
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.register(ReportTableViewCell.self, forCellReuseIdentifier: ReportTableViewCell.identifier)
    }
    
    /// 게시글 신고 후 홈으로 돌아가기
    private func goBackToHome() {
        // 1. ReportVC를 보여주고 있는 뷰컨트롤러를 찾고 (=tabbar controller)
        if let tabBarController = self.presentingViewController as? UITabBarController,
           // 2. 선택된 뷰컨트롤러에 접근 (=navigation controller)
           let navigationController = tabBarController.selectedViewController as? UINavigationController {
            // 3. 부모의 부모 뷰컨트롤러 (= home tab view controller)에 접근
            if let grandparentViewController = navigationController.viewControllers.dropLast().last {
                // 모달을 해제하고 그 후 네비게이션 스택에서 원하는 뷰컨트롤러로 이동
                self.dismiss(animated: true) {
                    navigationController.popToViewController(grandparentViewController, animated: true)
                }
            }
        }
    }
    
    func setPostId(_ postId: Int) {
        self.postId = postId
    }
}

// MARK: - Extension: UITableView

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportType.getReportTypeCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportTableViewCell.identifier, for: indexPath) as? ReportTableViewCell else { return UITableViewCell() }
        cell.configure(reportType: ReportType.getReportTypeAt(index: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.adjustedH
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ReportTableViewCell
        viewModel.reportPost(reportRequest: PostReportRequest(postId: postId!, reportType: cell.reportType!.rawValue), fromCurrentVC: self)
    }
}

// MARK: - Extension: CustomAlertDelegate

extension ReportViewController: CustomAlertDelegate {
    func confirmAction() {
        goBackToHome()
    }
    
    func cancel() {
    }
}
