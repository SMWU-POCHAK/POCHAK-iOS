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
    
    public var changeHasBeenMade: Bool = false {
        willSet {
            if(newValue){
                print("삭제돼서 다시 로딩할 예정")
                self.currentFetchingPage = 0
                self.postList.removeAll()
                self.setupData()
            }
        }
    }
    
    private var postList: [HomeDataPostList]! = []
    private var isLastPage: Bool = false
    private var currentFetchingPage: Int = 0
    private var homeDataResponse: HomeDataResponse!
    private var homeDataResult: HomeDataResult!
    
    private let minimumLineSpacing: CGFloat = 9
    private let minimumInterItemSpacing: CGFloat = 8
    private var noPost: Bool = false
    private var isCurrentlyFetching: Bool = false
    
    // MARK: - Views
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentFetchingPage = 0
        setupData()
        
        // set up collection view
        setupCollectionView()
        
        // 내비게이션 바에 로고 이미지
        let logoImage = UIImage(named: "logo_full")
        let logoImageView = UIImageView(image: logoImage)

        logoImageView.contentMode = .scaleAspectFit

        self.navigationItem.titleView = logoImageView
        
        // 네비게이션 바 줄 없애기
        self.navigationController?.navigationBar.standardAppearance.shadowColor = .white  // 스크롤하지 않는 상태
        self.navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = .white  // 스크롤하고 있는 상태
        
        // back 버튼 커스텀
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear - home")
        //currentFetchingPage = 0
        //self.setupData()
    }
    
    // MARK: - Action

    
    // MARK: - Functions
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
            
        collectionView.register(
            UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        collectionView.register(
            
            UINib(nibName: "NoPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoPostCollectionViewCell")
    }
    
    private func setupData(){
        isCurrentlyFetching = true
        // 임시로 유저 핸들 지수로
        HomeDataService.shared.getHomeData(page: currentFetchingPage) { response in
            switch response {
            case .success(let data):
                self.homeDataResponse = data as? HomeDataResponse
                self.homeDataResult = self.homeDataResponse.result
//                self.postList = self.homeDataResult.postList
                self.homeDataResult.postList.map { data in
                    self.postList.append(data)
                }
                
                if self.postList.count == 0 {
                    self.noPost = true
                }
                
                print("보여주는 게시글 개수: \(self.postList.count)")
                
                self.isLastPage = self.homeDataResult.pageInfo.lastPage
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    self.isCurrentlyFetching = false
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
        changeHasBeenMade = false
    }

}

// MARK: - Extensions; CollectionView

extension HomeTabViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noPost ? 1 : postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if noPost {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoPostCollectionViewCell", for: indexPath) as? NoPostCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell
            else{ return UICollectionViewCell()}
            
            /* 추후 수정 필요*/
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !noPost {
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = postList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    // cell의 위 아래 간격을 정함
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return noPost ? 0 : minimumLineSpacing
    }
    
    // cell 양 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return noPost ? 0 : minimumInterItemSpacing
    }
    
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if noPost {
            let mainBound = UIScreen.main.bounds.size
            let width = mainBound.width
            let height = self.collectionView.bounds.height
            return CGSize(width: width, height: height)
        }
        else {
            let width = CGFloat((collectionView.frame.width - 20 * 2 - minimumInterItemSpacing * 2) / 3)  // 20은 양 끝 간격
            return CGSize(width: width, height: width * 4 / 3)  // 3:4 비율로
        }
    }
}

// MARK: - Extension; UIScrollView

// TODO: 데이터 가져오는 에러 해결 필요
extension HomeTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!noPost && collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setupData()
            }
        }
    }
}
