//
//  FirstTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

protocol RemoveImageDelegate: AnyObject {
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String)
}

class FirstTabmanViewController: UIViewController{
    // MARK: - Data
    
    @IBOutlet weak var followerCollectionView: UICollectionView!
    var imageArray : [MemberListDataModel] = []
    var recievedHandle : String?
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionView 등록
        setupCollectionView()
        
        // API
        loadFollowerListData()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        // API
        loadFollowerListData()
    }

    // MARK: - Method
    
    private func setupCollectionView() {
        followerCollectionView.delegate = self
        followerCollectionView.dataSource = self
            
        // collection view에 셀 등록
        followerCollectionView.register(
            UINib(nibName: "FollowerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FollowerCollectionViewCell")
        }

    private func loadFollowerListData() {
        FollowListDataManager.shared.followerDataManager(recievedHandle ?? "",{resultData in
            self.imageArray = resultData
            self.followerCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
        })
    }
    
}

// MARK: - Extension

extension FirstTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell 생성
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FollowerCollectionViewCell.identifier,
            for: indexPath) as? FollowerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // 데이터 전달
        let memberListData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.configure(memberListData)
        cell.parentVC = self
        
        // delegate 위임받음
        cell.delegate = self
        return cell
    }
    
    // 유저 클릭 시 해당 프로필로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else {return}
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowerCollectionViewCell = self.followerCollectionView.cellForItem(at: indexPath) as? FollowerCollectionViewCell else {return}
        otherUserProfileVC.recievedHandle = cell.userId.text
    }

}

extension FirstTabmanViewController : UICollectionViewDelegateFlowLayout{
    
    // cell 높이, 너비 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followerCollectionView.bounds.width,
                      height: 70)
    }
    
    // cell 간 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// cell 삭제 로직
extension FirstTabmanViewController: RemoveImageDelegate {
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 18), NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: "팔로워를 삭제하시겠습니까?", attributes: titleAttributes as [NSAttributedString.Key : Any])
        
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Regular", size: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: "\n팔로워를 삭제하면, 팔로워와 관련된 \n사진이 사라집니다.", attributes: messageAttributes as [NSAttributedString.Key : Any])
        
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        cancelAction.setValue(UIColor(named: "gray05"), forKey: "titleTextColor")
        
        let okAction = UIAlertAction(title: "삭제하기", style: .default, handler: {
            action in
            // API
            DeleteFollowerDataManager.shared.deleteFollowerDataManager(self.recievedHandle ?? "", handle, { resultData in
                print(resultData.message)
            })
            // cell 삭제
            self.imageArray.remove(at: indexPath.row)
            self.followerCollectionView.reloadData()
        })
        okAction.setValue(UIColor(named: "yellow00"), forKey: "titleTextColor")

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil) // present는 VC에서만 동작
    }
}
