//
//  ExploreTabViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/04.
//

import UIKit
import Kingfisher

class PostTabViewController: UIViewController, UISearchBarDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
        
    @IBOutlet weak var searchBarView: UIView!
    private var postTabDataResponse: PostTabDataResponse!
    private var postTabDataResult: PostTabDataResult!
    private var postList: [PostTabDataPostList]! = []
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        currentFetchingPage = 0

        setupCollectionView()
        setSearchBarView()
        setupData()
        setupTapGestureOnSearchBarView()
        setRefreshControl()
   // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear search bar text and resign first responder when returning to this page
        self.navigationController?.isNavigationBarHidden = true
        
        // back 버튼 커스텀
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
    }


    private func setupCollectionView(){
        //delegate 연결
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //cell 등록
        collectionView.register(UINib(
            nibName: "PostCollectionViewCell",
            bundle: nil),forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        
    }

    private func setupData(){ // 서버 연결 시
        isCurrentlyFetching = true
        PostTabDataService.shared.recommandGet(page: currentFetchingPage){
            response in
                switch response {
                case .success(let data):
                    self.postTabDataResponse = data
                    guard let result = self.postTabDataResponse?.result else { return }
                
                    let newPosts = result.postList
                    let startIndex = self.postList.count
                    let endIndex = startIndex + newPosts.count
                    let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                    
                    self.postList.append(contentsOf: newPosts)
                    
                    self.isLastPage = result.pageInfo.lastPage
                    
                    DispatchQueue.main.async {
                        if self.currentFetchingPage == 0 {
                            self.collectionView.reloadData()
                        } else {
                            self.collectionView.insertItems(at: newIndexPaths)
                        }
                        self.isCurrentlyFetching = false
                        self.currentFetchingPage += 1;
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
    
    func setSearchBarView(){
        self.searchBarView.layer.cornerRadius = 7
        self.searchBarView.clipsToBounds = true
    }
    
    private func setupTapGestureOnSearchBarView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchBarViewTapped))
        searchBarView.addGestureRecognizer(tapGesture)
    }

    @objc private func searchBarViewTapped() {
        // 최근 검색어 화면으로 전환
        let storyboard = UIStoryboard(name: "PostTab", bundle: nil)
        if let recentSearchVC = storyboard.instantiateViewController(withIdentifier: "RecentSearchVC") as? RecentSearchViewController {
            self.navigationController?.pushViewController(recentSearchVC, animated: false)
        }
    }
    
    private func setRefreshControl(){
        // UIRefreshControl 생성
       let refreshControl = UIRefreshControl()
       refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

       // 테이블 뷰에 UIRefreshControl 설정
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        print("refresh")
        self.postList = []
        self.currentFetchingPage = 0
        self.setupData()
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
}


//MARK: - 포스트 collectionView
extension PostTabViewController: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else{
            fatalError("셀 타입 캐스팅 실패2")
        }
        // 이미지 설정
        if(!postList.isEmpty){
            cell.configure(with: postList[indexPath.item].postImage)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("view post btn tapped")
        let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
        guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        
        postVC.receivedPostId = postList[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}

        
extension PostTabViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4.5, left: 20, bottom: 4.5, right: 20)
        }
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
        }

            
    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let width = (collectionView.frame.width-56) / 3 // 두 번째 섹션의 셀 너비
        let height = width * 4 / 3 // 셀의 가로:세로 비율
        return CGSize(width: width, height: height) // 두 번째 섹션의 셀 크기
        
       
    }
}

// MARK: - Extension; UIScrollView

extension PostTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setupData()
            }
        }
    }
}
