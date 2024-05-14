//
//  AlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/11.
//

import UIKit

class AlarmViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private var alarmDataResponse: AlarmResponse!
    private var alarmDataResult: AlarmResult!
    private var alarmList: [AlarmElementList]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-bold", size: 20)!]
        self.navigationItem.title = "알림"
        
        // Do any additional setup after loading the view.
        setupCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadAlarmData()

    }
    private func setupCollectionView(){
        //delegate 연결
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //cell 등록
        collectionView.register(UINib(
            nibName: "AlarmCollectionViewCell",
            bundle: nil),
            forCellWithReuseIdentifier: AlarmCollectionViewCell.identifier)
        
        collectionView.register(UINib(
            nibName: "OtherCollectionViewCell",
            bundle: nil),
            forCellWithReuseIdentifier: OtherCollectionViewCell.identifier)
    }

    func loadAlarmData(){
        AlarmDataService.shared.getAlarm { [self]
            response in
            switch response {
            case .success(let data):
                print("success")
                
                self.alarmDataResponse = data as? AlarmResponse
                self.alarmDataResult = self.alarmDataResponse.result
                print(self.alarmDataResult!)
                self.alarmList = self.alarmDataResult.alarmElementList
                print(self.alarmList)
                DispatchQueue.main.async {
                    self.collectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
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

}

extension AlarmViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.alarmList)
        return self.alarmList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MARK: - 누군가 날 게시물에 태그했을 경우 TAG_APPROVAL
        if(self.alarmList[indexPath.item].alarmType == AlarmType.tagApproval){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlarmCollectionViewCell.identifier, for: indexPath) as? AlarmCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.item].ownerHandle {
                // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                cell.comment.text = "\(userSentAlarmHandle) 님이 회원님을 포착했습니다."
            }
            if let image = self.alarmList[indexPath.item].ownerProfileImage{
                cell.configure(with: image)

            }
            
            // Set up button actions
           cell.acceptButtonAction = {
               // Handle accept button tap
               if let tagId = self.alarmList[indexPath.item].tagId {
                   // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                   self.postTagData(tagId: tagId, isAccept: true)
               }
           }

            cell.refuseButtonAction = {
                // Handle refuse button tap
                if let tagId = self.alarmList[indexPath.item].tagId {
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    self.postTagData(tagId: tagId, isAccept: false)
                }
            }

            return cell
        }
        // MARK: - 댓글(내가 올린 게시물에 댓글이 달렸을 경우 OWNER_COMMENT)
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.ownerComment){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherCollectionViewCell.identifier, for: indexPath) as? OtherCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.item].memberHandle {
                if let comment = alarmList[indexPath.item].commentContent{
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    cell.comment.text = "\(userSentAlarmHandle) 님이 댓글을 달았습니다. : \(comment)"
                }
            }
            if let image = self.alarmList[indexPath.item].memberProfileImage{
                cell.configure(with: image)

            }
            return cell
        }
        // MARK: - 댓글 (내가 태그된 게시물에 댓글이 달렸을 경우 TAGGED_COMMENT)
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.taggedComment){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherCollectionViewCell.identifier, for: indexPath) as? OtherCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.item].memberHandle {
                if let comment = alarmList[indexPath.item].commentContent{
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    cell.comment.text = "내가 포착된 게시물에 \(userSentAlarmHandle) 님이 댓글을 달았습니다. : \(comment)"
                }
            }
            if let image = self.alarmList[indexPath.item].memberProfileImage{
                cell.configure(with: image)

            }
            return cell
        }
        // MARK: - 댓글 (내 댓글에 답글이 달렸을 경우 COMMENT_REPLY)
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.commentReply){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherCollectionViewCell.identifier, for: indexPath) as? OtherCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.item].memberHandle {
                if let comment = alarmList[indexPath.item].commentContent{
                    // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                    cell.comment.text = "나의 댓글에 \(userSentAlarmHandle) 님이 답글을 달았습니다. : \(comment)"
                }
            }
            if let image = self.alarmList[indexPath.item].memberProfileImage{
                cell.configure(with: image)

            }
            return cell
        }
        // MARK: - 다른 사람이 날 팔로우했을 경우 FOLLOW
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.follow){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherCollectionViewCell.identifier, for: indexPath) as? OtherCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.item].handle {
                // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                cell.comment.text = "\(userSentAlarmHandle) 님이 회원님을 팔로우하였습니다."
            }
            if let image = self.alarmList[indexPath.item].profileImage{
                cell.configure(with: image)

            }
            return cell
        }
        // MARK: - 내가 올린 게시물에 좋아요가 달릴 경우 LIKE
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.like){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherCollectionViewCell.identifier, for: indexPath) as? OtherCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            if let userSentAlarmHandle = self.alarmList[indexPath.item].memberHandle {
                // 옵셔널이 아닌 문자열 값을 추출하여 사용합니다.
                cell.comment.text = "\(userSentAlarmHandle) 님이 좋아요를 눌렀습니다."
            }
            if let image = self.alarmList[indexPath.item].memberProfileImage{
                cell.configure(with: image)

            }
            return cell
        }
        else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlarmCollectionViewCell.identifier, for: indexPath) as? AlarmCollectionViewCell else{
                        fatalError("셀 타입 캐스팅 실패")
            }
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(self.alarmList[indexPath.item].alarmType == AlarmType.tagApproval){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
            
        }
        // MARK: - 댓글(내가 올린 게시물에 댓글이 달렸을 경우 OWNER_COMMENT)
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.ownerComment){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        // MARK: - 댓글 (내가 태그된 게시물에 댓글이 달렸을 경우 TAGGED_COMMENT)
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.taggedComment){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        // MARK: - 댓글 (내 댓글에 답글이 달렸을 경우 COMMENT_REPLY)
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.commentReply){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
        // MARK: - 다른 사람이 날 팔로우했을 경우 FOLLOW
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.follow){
            let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
            let profileTabVC = storyboard.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileViewController
            
            profileTabVC.recievedHandle = alarmList[indexPath.item].handle
            self.navigationController?.pushViewController(profileTabVC, animated: true)
        }
        // MARK: - 내가 올린 게시물에 좋아요가 달릴 경우 LIKE
        else if(self.alarmList[indexPath.item].alarmType == AlarmType.like){
            // 게시물로 이동
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = alarmList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    func postTagData(tagId: Int, isAccept: Bool){
        AlarmDataService.shared.postTagAccept(tagId: tagId, isAccept: isAccept){ [self]
            response in
            switch response {
            case .success(let data):
                print(data)
                DispatchQueue.main.async {
                    loadAlarmData() // collectionView를 새로고침하여 이미지 업데이트
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
}
    
extension AlarmViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width - 48
        
        let size = CGSize(width: width, height: width)
        return size
    }
}

