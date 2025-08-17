//
//  AlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/11.
//

import UIKit

final class AlarmViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    // MARK: - Properties
    
    private var alarmList: [AlarmElementList]! = []
    
    private var isLastPage: Bool = false
    private var currentFetchingPage: Int = 0
    private var isCurrentlyFetching: Bool = false
    
    // MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "알림"
        
        currentFetchingPage = 0

        setupTableView()
        setRefreshControl()
        loadAlarmData()
        
        // 모달창 닫겼는지 확인
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData(_:)), name: Notification.Name("ModalDismissed"), object: nil)
    }
    
    // MARK: - Actions
    
    @objc func loadAlarmData() {
        isCurrentlyFetching = true
        
        let request = AlarmListRequest(page: currentFetchingPage)
        AlarmService.getAlarmList(request: request) { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription),
                                  animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "알림 목록 요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            guard let self = self else { return }
            
            let newResult = data.result.alarmList
            let startIndex = self.alarmList.count
            let endIndex = startIndex + newResult.count
            let newIndexPaths = (startIndex ..< endIndex).map { IndexPath(item: $0, section: 0) }
            
            self.alarmList.append(contentsOf: newResult)
            self.isLastPage = data.result.pageInfo.lastPage
            
            print("+++++++alarmList : \(self.alarmList)")
            
            DispatchQueue.main.async {
                if self.currentFetchingPage == 0 {
                    self.tableView.reloadData()
                } else {
                    self.tableView.insertRows(at: newIndexPaths, with: .none)
                }
                self.isCurrentlyFetching = false
                self.currentFetchingPage += 1;
                
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func reloadData(_ sender: Any) {
        currentFetchingPage = 0
        alarmList = []
        loadAlarmData()
    }
    
    @objc private func refreshData(_ sender: Any) {
        currentFetchingPage = 0
        alarmList = []
//        loadAlarmData()
//        DispatchQueue.main.async {
//            self.tableView.refreshControl?.endRefreshing()
//        }
        tableView.reloadData()
        
        loadAlarmData()
    }
    
    // MARK: - Functions
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: OtherTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: OtherTableViewCell.identifier)
        tableView.register(UINib(nibName: PochakAlarmTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PochakAlarmTableViewCell.identifier)
        tableView.register(UINib(nibName: MomentAlarmTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MomentAlarmTableViewCell.identifier)
    }
    
    private func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

// MARK: - Extension: TableView

extension AlarmViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let alarm = self.alarmList[indexPath.row]
        let alarmType = alarm.alarmType

        switch alarmType {
        case .tagApproval:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PochakAlarmTableViewCell.identifier, for: indexPath) as? PochakAlarmTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            
            configurePochakAlarmCell(cell, with: alarm)
            return cell

        case .ownerComment, .taggedComment, .commentReply:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            
            let userSentAlarmHandle = alarm.memberHandle ?? ""
            let comment = alarm.commentContent ?? ""
            let time = alarm.createdDate.getTimeIntervalOfDateAndNow()
            
            let text: String
            switch alarmType {
            case .ownerComment:
                text = "\(userSentAlarmHandle) 님이 댓글을 달았습니다. : \(comment)"
            case .taggedComment:
                text = "내가 포착된 게시물에 \(userSentAlarmHandle) 님이 댓글을 달았습니다. : \(comment)"
            case .commentReply:
                text = "나의 댓글에 \(userSentAlarmHandle) 님이 답글을 달았습니다. : \(comment)"
            default:
                text = ""
            }
            
            configureCell(cell, with: alarm, comment: text, time: time)
            return cell

        case .follow:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            let time = alarm.createdDate.getTimeIntervalOfDateAndNow()
            let text = "\(alarm.memberHandle ?? "") 님이 회원님을 팔로우하였습니다."
            configureCell(cell, with: alarm, comment: text, time: time)
            return cell

        case .ownerLike:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            let time = alarm.createdDate.getTimeIntervalOfDateAndNow()
            let text = "내 게시물에 \(alarm.memberHandle ?? "") 님이 좋아요를 눌렀습니다."
            configureCell(cell, with: alarm, comment: text, time: time)
            return cell

        case .taggedLike:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            let time = alarm.createdDate.getTimeIntervalOfDateAndNow()
            let text = "내가 포착된 게시물에 \(alarm.memberHandle ?? "") 님이 좋아요를 눌렀습니다."
            configureCell(cell, with: alarm, comment: text, time: time)
            return cell
            
        case .momentPost:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MomentAlarmTableViewCell.identifier, for: indexPath) as? MomentAlarmTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            configureMomentAlarmCell(cell, with: alarm)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarm = self.alarmList[indexPath.row]
        
        // 확인하지 않은 알람인 경우 확인api 요청
        if !alarm.isChecked {
            AlarmService.postCheckAlarm(alarmId: alarm.alarmId) { [weak self] data, failed in
                guard let data = data else {
                    switch failed {
                    case .disconnected:
                        self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription),
                                      animated: true)
                    default:
                        self?.present(UIAlertController.networkErrorAlert(title: "알림 확인에 실패하였습니다."), animated: true)
                    }
                    return
                }
            }
        }
        
        switch alarm.alarmType {
        case .tagApproval:
            self.tableView.deselectRow(at: indexPath, animated: false)

        case .follow:
            let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
            let profileTabVC = OtherUserProfileViewController()
            
            profileTabVC.receivedHandle = alarmList[indexPath.row].memberHandle
            self.navigationController?.pushViewController(profileTabVC, animated: true)
            
        case .ownerComment, .taggedComment, .commentReply, .ownerLike, .taggedLike, .momentPost:
            let postVC = PostViewController()
            
            postVC.receivedPostId = alarmList[indexPath.row].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func configureCell(_ cell: OtherTableViewCell, with alarm: AlarmElementList, comment: String, time: String) {
        cell.comment.text = comment
        cell.timeLabel.text = "\(time) 전"
        if let url = URL(string: alarm.memberProfileImage ?? "") {
            cell.img.load(with: url)
            cell.img.contentMode = .scaleAspectFill
        }
        
        if !alarm.isChecked {
            cell.contentView.backgroundColor = UIColor(hexCode: "FFF1D8", alpha: 0.7)
        }
        else {
            cell.contentView.backgroundColor = .white
        }
    }

    func configurePochakAlarmCell(_ cell: PochakAlarmTableViewCell, with alarm: AlarmElementList) {
        if let userSentAlarmHandle = alarm.ownerHandle {
            cell.comment.text = "\(userSentAlarmHandle) 님이 회원님을 포착했습니다."
        }
        
        if let url = URL(string: alarm.ownerProfileImage ?? "") {
            cell.img.load(with: url)
            cell.img.contentMode = .scaleAspectFill
        }
        
        if let url = URL(string: alarm.postImage ?? "") {
            cell.previewImageView.load(with: url)
        }
        
        cell.timeLabel.text = "\(alarm.createdDate.getTimeIntervalOfDateAndNow()) 전"
        
        cell.previewBtnClickAction = {
            guard let tagId = alarm.tagId else {
                print("tagId is nil")
                return
            }
            
            let previewAlarmVC = UIStoryboard(name: "AlarmTab", bundle: nil).instantiateViewController(withIdentifier: "PreviewAlarmVC") as! PreviewAlarmViewController
            previewAlarmVC.tagId = tagId
            previewAlarmVC.alarmId = alarm.alarmId
            previewAlarmVC.modalPresentationStyle = .pageSheet
            
            if let sheet = previewAlarmVC.sheetPresentationController {
                sheet.detents = [
                    .custom { _ in
                        return previewAlarmVC.postImageView.frame.maxY + 13
                    }
                ]
                sheet.delegate = self
                sheet.prefersGrabberVisible = true
            }
            self.present(previewAlarmVC, animated: true)
        }
        
        if !alarm.isChecked {
            cell.contentView.backgroundColor = UIColor(hexCode: "FFF1D8", alpha: 0.7)
        }
        else {
            cell.contentView.backgroundColor = .white
        }
    }
    
    func configureMomentAlarmCell(_ cell: MomentAlarmTableViewCell, with alarm: AlarmElementList) {
        if let user1 = alarm.ownerHandle, let user2 = alarm.memberHandle {
            cell.alarmContentLabel.text = "\(user1) 님과 \(user2)님이 서로를 순간 포착했습니다."
        }
        
        if let url = URL(string: alarm.ownerProfileImage ?? "") {
            cell.userImageView1.load(with: url)
        }
        
        if let url = URL(string: alarm.memberProfileImage ?? "") {
            cell.userImageView2.load(with: url)
        }
        
        if let url = URL(string: alarm.postImage ?? "") {
            cell.previewImageView.load(with: url)
        }
        
        cell.timeLabel.text = "\(alarm.createdDate.getTimeIntervalOfDateAndNow()) 전"
        
        cell.previewBtnClickAction = {
            guard let tagId = alarm.tagId else {
                print("tagId is nil")
                return
            }
            
            let previewAlarmVC = UIStoryboard(name: "AlarmTab", bundle: nil).instantiateViewController(withIdentifier: "PreviewAlarmVC") as! PreviewAlarmViewController
            previewAlarmVC.tagId = tagId
            previewAlarmVC.alarmId = alarm.alarmId
            previewAlarmVC.modalPresentationStyle = .pageSheet
            
            if let sheet = previewAlarmVC.sheetPresentationController {
                sheet.detents = [
                    .custom { _ in
                        return previewAlarmVC.postImageView.frame.maxY + 13
                    }
                ]
                sheet.delegate = self
                sheet.prefersGrabberVisible = true
            }
            self.present(previewAlarmVC, animated: true)
        }
        
        if !alarm.isChecked {
            cell.contentView.backgroundColor = UIColor(hexCode: "FFF1D8", alpha: 0.7)
        }
        else {
            cell.contentView.backgroundColor = .white
        }
    }
}

// MARK: - Protocol : Modal

protocol UpdateDelegate: AnyObject {
    func modalDidDismiss()
}

// MARK: - Extension: UIScrollView

extension AlarmViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tableView.contentOffset.y > (tableView.contentSize.height - tableView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                loadAlarmData()
            }
        }
    }
}
