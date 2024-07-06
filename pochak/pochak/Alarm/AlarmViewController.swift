//
//  AlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/11.
//

import UIKit

class AlarmViewController: UIViewController, UISheetPresentationControllerDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    
    private var alarmDataResponse: AlarmResponse!
    private var alarmDataResult: AlarmResult!
    private var alarmList: [AlarmElementList]! = []
    
    private let alarmStoryBoard = UIStoryboard(name: "AlarmTab", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "알림"
        
        // Do any additional setup after loading the view.
        setupTableView()
        setRefreshControl()
        
        // 모달창 닫겼는지 확인
        NotificationCenter.default.addObserver(self, selector: #selector(loadAlarmData), name: Notification.Name("ModalDismissed"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAlarmData()
    }

    private func setupTableView() {
        // delegate 연결
        tableView.delegate = self
        tableView.dataSource = self
                        
        tableView.separatorStyle = .none
        // cell 등록
        tableView.register(UINib(nibName: "OtherTableViewCell", bundle: nil), forCellReuseIdentifier: OtherTableViewCell.identifier)
        tableView.register(UINib(nibName: "PochakAlarmTableViewCell", bundle: nil), forCellReuseIdentifier: PochakAlarmTableViewCell.identifier)
    }

    @objc func loadAlarmData() {
        AlarmDataService.shared.getAlarm { [self] response in
            switch response {
            case .success(let data):
                print("success")
                
                self.alarmDataResponse = data as? AlarmResponse
                self.alarmDataResult = self.alarmDataResponse.result
                print(self.alarmDataResult!)
                self.alarmList = self.alarmDataResult.alarmList
                print(self.alarmList)
                DispatchQueue.main.async {
                    self.tableView.reloadData() // tableView를 새로고침하여 이미지 업데이트
                }
            case .requestErr(let err):
                print(err)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    private func setRefreshControl(){
        // UIRefreshControl 생성
       let refreshControl = UIRefreshControl()
       refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

       // 테이블 뷰에 UIRefreshControl 설정
       tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        self.loadAlarmData()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension AlarmViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("alarmList")
        return self.alarmList.count 
    }
    
    // TODO: 여기 부분 switch-case 로 바꾸면 훨씬 좋을 것 같음..!!!!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MARK: - 누군가 날 게시물에 태그했을 경우 TAG_APPROVAL
        if(self.alarmList[indexPath.row].alarmType == AlarmType.tagApproval){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PochakAlarmTableViewCell.identifier, for: indexPath) as? PochakAlarmTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.row].ownerHandle {
                // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                cell.comment.text = "\(userSentAlarmHandle) 님이 회원님을 포착했습니다."
            }
            if let image = self.alarmList[indexPath.row].ownerProfileImage {
                cell.configure(with: image)
            }
            
            // Set up button actions
            cell.previewBtnClickAction = {
                // Handle accept button tap
                guard let tagId = self.alarmList[indexPath.row].tagId else {
                    print("tagId is nil")
                    return
                }
                
                let previewAlarmVC = self.alarmStoryBoard.instantiateViewController(withIdentifier: "PreviewAlarmVC") as! PreviewAlarmViewController
                previewAlarmVC.tagId = tagId
                previewAlarmVC.alarmId = self.alarmList[indexPath.row].alarmId
                
                // 모달 창의 presentation style을 .pageSheet로 설정합니다.
                previewAlarmVC.modalPresentationStyle = .pageSheet
                
                // sheetPresentationController를 이용하여 detent 설정
                if let sheet = previewAlarmVC.sheetPresentationController {
                    sheet.detents = [
                        .custom { _ in
                            return previewAlarmVC.postImageView.frame.maxY + 13 // 원하는 높이를 반환
                        }
                    ]
                    
                    sheet.delegate = self // sheet의 delegate 설정
                    sheet.prefersGrabberVisible = true // grabber(핸들) 표시 여부 설정
                }
                
                // previewAlarmVC를 present하여 모달 창을 엽니다.
                self.present(previewAlarmVC, animated: true)
            }
    
            return cell
        }
        // MARK: - 댓글(내가 올린 게시물에 댓글이 달렸을 경우 OWNER_COMMENT)
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.ownerComment){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.row].memberHandle {
                if let comment = alarmList[indexPath.row].commentContent {
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    cell.comment.text = "\(userSentAlarmHandle) 님이 댓글을 달았습니다. : \(comment)"
                }
            }
            if let image = self.alarmList[indexPath.row].memberProfileImage {
                cell.configure(with: image)
            }
            return cell
        }
        // MARK: - 댓글 (내가 태그된 게시물에 댓글이 달렸을 경우 TAGGED_COMMENT)
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.taggedComment){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.row].memberHandle {
                if let comment = alarmList[indexPath.row].commentContent {
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    cell.comment.text = "내가 포착된 게시물에 \(userSentAlarmHandle) 님이 댓글을 달았습니다. : \(comment)"
                }
            }
            if let image = self.alarmList[indexPath.row].memberProfileImage {
                cell.configure(with: image)
            }
            return cell
        }
        // MARK: - 댓글 (내 댓글에 답글이 달렸을 경우 COMMENT_REPLY)
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.commentReply){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.row].memberHandle {
                if let comment = alarmList[indexPath.row].commentContent {
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    cell.comment.text = "나의 댓글에 \(userSentAlarmHandle) 님이 답글을 달았습니다. : \(comment)"
                }
            }
            if let image = self.alarmList[indexPath.row].memberProfileImage {
                cell.configure(with: image)
            }
            return cell
        }
        // MARK: - 다른 사람이 날 팔로우했을 경우 FOLLOW
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.follow){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.row].memberHandle {
                // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                cell.comment.text = "\(userSentAlarmHandle) 님이 회원님을 팔로우하였습니다."
            }
            if let image = self.alarmList[indexPath.row].memberProfileImage {
                cell.configure(with: image)
            }
            return cell
        }
        // MARK: - 내가 올린 게시물에 좋아요가 달릴 경우 OWNER_LIKE
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.ownerLike) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            
            if let userSentAlarmHandle = self.alarmList[indexPath.row].memberHandle {
                cell.comment.text = "내 게시물에 \(userSentAlarmHandle)님이 좋아요를 눌렀습니다."
            }
            
            if let image = self.alarmList[indexPath.row].memberProfileImage {
                cell.configure(with: image)
            }
            return cell
        }
        
        // MARK: - 내가 포착된 게시물에 좋아요가 달릴 경우 TAGGED_LIKE
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.taggedLike) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            
            if let userSentAlarmHandle = self.alarmList[indexPath.row].memberHandle {
                cell.comment.text = "내가 포착된 게시물에 \(userSentAlarmHandle)님이 좋아요를 눌렀습니다."
            }
            
            if let image = self.alarmList[indexPath.row].memberProfileImage {
                cell.configure(with: image)
            }
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherTableViewCell.identifier, for: indexPath) as? OtherTableViewCell else {
                fatalError("셀 타입 캐스팅 실패")
            }
            return cell
        }
    }
    
    // TODO: 여기도 switch-case..!!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.alarmList[indexPath.row].alarmType == AlarmType.tagApproval){
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        // MARK: - 댓글(내가 올린 게시물에 댓글이 달렸을 경우 OWNER_COMMENT)
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.ownerComment){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.row].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        // MARK: - 댓글 (내가 태그된 게시물에 댓글이 달렸을 경우 TAGGED_COMMENT)
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.taggedComment){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.row].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        // MARK: - 댓글 (내 댓글에 답글이 달렸을 경우 COMMENT_REPLY)
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.commentReply){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.row].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        // MARK: - 다른 사람이 날 팔로우했을 경우 FOLLOW
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.follow){
            let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
            let profileTabVC = storyboard.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileViewController
            
            profileTabVC.recievedHandle = alarmList[indexPath.row].memberHandle
            self.navigationController?.pushViewController(profileTabVC, animated: true)
        }
        // MARK: - 내 게시물 혹은 내가 포착된 게시물에 좋아요가 달릴 경우 OWNER_LIKE, TAGGED_LIKE
        else if(self.alarmList[indexPath.row].alarmType == AlarmType.ownerLike
                || self.alarmList[indexPath.row].alarmType == AlarmType.taggedLike){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.row].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
}

// 모달창 dismiss하고 알람 data 업데이트
protocol UpdateDelegate: AnyObject {
    func modalDidDismiss()
}
