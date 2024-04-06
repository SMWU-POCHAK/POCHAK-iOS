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
    @IBOutlet weak var followerCollectionView: UICollectionView!
    var imageArray : [MemberListDataModel] = []
    var recievedHandle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Collection View 구현
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        // API
        loadFollowerListData()
    }


    // MARK: - Helper
    private func setupCollectionView() {
        followerCollectionView.delegate = self
        followerCollectionView.dataSource = self
            
        // collection view에 셀 등록
        followerCollectionView.register(
            UINib(nibName: "FollowerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FollowerCollectionViewCell")
        }

    private func loadFollowerListData() {
//        let handle = "dxxynni" // !!임시 핸들!!
        FollowListDataManager.shared.followerDataManager(recievedHandle ?? "",{resultData in
            self.imageArray = resultData
            self.followerCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
        })
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
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
        // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        let memberListData = imageArray[indexPath.item]
        cell.configure(memberListData)
        cell.parentVC = self
        
        // delegate 위임받음
        cell.delegate = self
        return cell
    }
    
    // 유저 프로필 클릭시 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else {return}
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowerCollectionViewCell = self.followerCollectionView.cellForItem(at: indexPath) as? FollowerCollectionViewCell else {return}
        otherUserProfileVC.recievedHandle = cell.userId.text
    }

}

// CollectionView Cell 크기(높이, 너비 지정)
extension FirstTabmanViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followerCollectionView.bounds.width,
                      height: 80)
    }
    
}

// cell 삭제 로직
extension FirstTabmanViewController: RemoveImageDelegate {
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String) {
        // 알람! : 팔로워에서 삭제하시겠습니까?
        let alert = UIAlertController(title:"팔로워를 삭제하시겠습니까?",message: "",preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        let ok = UIAlertAction(title: "삭제", style: .destructive, handler: {
            action in
            // API
            DeleteFollowerDataManager.shared.deleteFollowerDataManager(handle, { resultData in
                print(resultData.message)
            })
            // cell 삭제
            print("inside removeFromCollectionView!!!!!")
//            self.followerCollectionView.deleteItems(at: [IndexPath(item: indexPath.row, section: 0)])
            self.imageArray.remove(at: indexPath.row)
            self.followerCollectionView.reloadData()
        })
        alert.addAction(cancle)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil) // present는 VC에서만 동작
    }
}
