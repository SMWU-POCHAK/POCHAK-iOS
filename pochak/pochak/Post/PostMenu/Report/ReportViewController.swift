//
//  ReportViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

class ReportViewController: UIViewController {
    
    // MARK: - Properties
    
    private let reportReasons = [
                                    "마음에 들지 않습니다.",
                                    "스팸",
                                    "나체 이미지 또는 성적 행위",
                                    "사기 또는 거짓",
                                    "혐오 발언 또는 상징",
                                    "거짓 정보"
                                ]
    private var postId: Int?

    // MARK: - Views
    
    @IBOutlet weak var reportTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTableView()
    }
    
    // MARK: - Functions
    
    private func setTableView() {
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.register(UINib(nibName: ReportTableViewCell.identifier, bundle: nil),
                                 forCellReuseIdentifier: ReportTableViewCell.identifier)
    }
    
    private func makeAlertController() -> UIAlertController{
        let alertVC = UIAlertController(title: "신고가 완료되었습니다.", message: "신고해주셔서 감사합니다.\n빠른 시일 내에 해결하겠습니다.", preferredStyle: UIAlertController.Style.alert)
        alertVC.setTitleFont()
        alertVC.setMessageFont()
        
        alertVC.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
            // reportVC dismiss -> 포스트 상세 보기로 다시 가기
            self.dismiss(animated: true)
        })
        
        return alertVC
    }
    
    func setPostId(_ postId: Int){
        self.postId = postId
    }
}

// MARK: - Extension: UITableView

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportReasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportTableViewCell.identifier, for: indexPath) as? ReportTableViewCell
        else { return UITableViewCell() }
        cell.reportReasonLabel.text = reportReasons[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReportReason = reportReasons[indexPath.row]
        print("신고 사유: \(selectedReportReason)")
        print("신고 게시물 아이디: \(postId)")
        
        // TODO: 신고 기능 api 연결 후 completion으로 알림창 띄우기
        
        let alert = makeAlertController()
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
