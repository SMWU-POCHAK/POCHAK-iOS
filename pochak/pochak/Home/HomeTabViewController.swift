//
//  HomeTabViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/05.
//

import UIKit
import Kingfisher

class HomeTabViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var postList: [HomeDataPostList]! = []
    private var isLastPage: Bool = false
    private var currentFetchingPage: Int = 0
    private var homeDataResponse: HomeDataResponse!
    private var homeDataResult: HomeDataResult!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        // set up collection view
        setupCollectionView()
        
        // 내비게이션 바에 로고 이미지
        let logoImage = UIImage(named: "logo_full")
        let logoImageView = UIImageView(image: logoImage)

        logoImageView.contentMode = .scaleAspectFit

        self.navigationItem.titleView = logoImageView
        
        // 네비게이션 바 줄 없애기
        //self.navigationController?.navigationBar.shadowImage = UIImage() -> 안됨
        // self.navigationController?.navigationBar.standardAppearance.shadowImage = UIImage() -> 안됨...
        self.navigationController?.navigationBar.standardAppearance.shadowColor = .white  // 스크롤하지 않는 상태
        self.navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = .white  // 스크롤하고 있는 상태
        
        // back 버튼 커스텀
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear - home")
        currentFetchingPage = 0
        self.setupData()
    }
    
    // MARK: - Action

    
    // MARK: - Helper
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
            
        // collection view에 셀 등록
        collectionView.register(
            UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    
    private func setupData(){
        // 임시로 유저 핸들 지수로
        HomeDataService.shared.getHomeData(page: currentFetchingPage) { response in
            switch response {
            case .success(let data):
                print(data)
                self.homeDataResponse = data as? HomeDataResponse
                self.homeDataResult = self.homeDataResponse.result
                print(self.homeDataResult!)
                self.postList = self.homeDataResult.postList
                print(self.postList)
                self.isLastPage = self.homeDataResult.pageInfo.lastPage
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                }
                self.currentFetchingPage += 1;  // 다음 페이지로
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

// MARK: - Extensions
extension HomeTabViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // section 당 아이템 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    // cell 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell
        else{ return UICollectionViewCell()}
        
        //cell.prepare()
        /* 추후 수정 필요*/
        // cell.setupData()
//        cell.imageView.kf.setImage(with: imageArray[indexPath.item].imgUrl)
        //url = URL(string: imageArray[indexPath.item].imgUrl)
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: (self?.postList[indexPath.item].postImage)!)!) {
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        cell.prepare(image: image)
                        cell.imageView.contentMode = .scaleAspectFill
                    }
                }
            }
        }
        return cell
    }
    
    /* 서버 연결 후 수정 */
    // cell 클릭 시 해당 게시물로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
        guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        
        postVC.receivedPostId = postList[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    // cell의 위 아래 간격을 정함
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    // cell 양 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = CGFloat((collectionView.frame.width - 58) / 3)  // 24+24+5+5 = 58
        return CGSize(width: width, height: width * 4 / 3)  // 3:4 비율로
    }
}

extension HomeTabViewController: UIScrollViewDelegate {
    // 스크롤이 끝까지 닿았는지 판단 .. 50% 로?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height)){
            if (!isLastPage) {
                setupData()
            }
        }
    }
}
