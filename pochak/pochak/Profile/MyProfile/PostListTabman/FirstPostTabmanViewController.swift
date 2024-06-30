//
//  FirstPostTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class FirstPostTabmanViewController: UIViewController {
    
    // MARK: - Data
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    var receivedHandle: String?
    var imageArray : [PostDataModel] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Collection View 구현
        setupCollectionView()
        
        // API
        loadImageData()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        // API
        loadImageData()
    }

    // MARK: - Funtion
    
    private func setupCollectionView() {
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
            
        // collection view에 셀 등록
        postCollectionView.register(
            UINib(nibName: "ProfilePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfilePostCollectionViewCell")
        }
    
    private func loadImageData() {
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(receivedHandle ?? "",{resultData in
            self.imageArray = resultData.postList
            self.postCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
        })
    }
}

// MARK: - Extension

extension FirstPostTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell 생성
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePostCollectionViewCell.identifier,
            for: indexPath) as? ProfilePostCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let postData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.configure(postData)
        return cell
    }
    
    // cell 상하 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    // cell 옆 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // cell 좌우 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat((collectionView.frame.width - 10) / 3)
        return CGSize(width: width, height: width * 4 / 3)
    }
    
    // post 클릭 시 해당 post로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
        guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        postVC.receivedPostId = imageArray[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}
