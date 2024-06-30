//
//  SecondTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class SecondTabmanViewController: UIViewController {
    
    // MARK: - Data

    @IBOutlet weak var followingCollectionView: UICollectionView!
    var imageArray : [MemberListDataModel] = []
    var recievedHandle : String?

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // CollectionView 등록
        setupCollectionView()
        
        // API
        loadFollowingListData()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        // API
        loadFollowingListData()
    }

    // MARK: - Method

    private func setupCollectionView() {
        followingCollectionView.delegate = self
        followingCollectionView.dataSource = self
            
        // collection view에 셀 등록
        followingCollectionView.register(
            UINib(nibName: "FollowingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FollowingCollectionViewCell")
        }
    
    private func loadFollowingListData() {
        FollowListDataManager.shared.followingDataManager(recievedHandle ?? "",{resultData in
            self.imageArray = resultData
            self.followingCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
        })
    }
    
}

// MARK: - Extension

extension SecondTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell 생성
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FollowingCollectionViewCell.identifier,
            for: indexPath) as? FollowingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // 데이터 전달
        let memberListData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.configure(memberListData)
        return cell
    }
    
    //  유저 클릭 시 해당 프로필로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else {return}
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowingCollectionViewCell = self.followingCollectionView.cellForItem(at: indexPath) as? FollowingCollectionViewCell else {return}
        otherUserProfileVC.recievedHandle = cell.userId.text
    }
}

extension SecondTabmanViewController : UICollectionViewDelegateFlowLayout{
    // cell 높이, 너비 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followingCollectionView.bounds.width,
                      height: 70)
    }
    
    // cell 간 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
