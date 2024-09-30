//
//  SecondPostTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class PochakPostTabmanViewController: UIViewController {
    
    // MARK: - Properties
    
    var receivedHandle: String?
    var imageArray: [ProfilePostList] = []
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - Views
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentFetchingPage = 0
        
        setUpCollectionView()
        setUpRefreshControl()
        setUpData()
    }
    
    // MARK: - Actions
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        print("refresh")
        imageArray = []
        currentFetchingPage = 0
        setUpData()
        DispatchQueue.main.async {
            self.postCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private func setUpCollectionView() {
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        postCollectionView.register(
            UINib(nibName: ProfilePostCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identifier)
    }
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        postCollectionView.refreshControl = refreshControl
    }
    
    private func setUpData() {
        isCurrentlyFetching = true
        let request = ProfileRetrievalRequest(page: currentFetchingPage)
        
        ProfileService.getProfilePochakPosts(handle: receivedHandle ?? "", request: request) { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            let newPosts = data.result.postList
            let startIndex = data.result.postList.count
            let endIndex = startIndex + newPosts.count
            let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
            self?.imageArray.append(contentsOf: newPosts)
            self?.isLastPage = data.result.pageInfo.lastPage
            
            DispatchQueue.main.async {
                if self?.currentFetchingPage == 0 {
                    self?.postCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    print(">>>>>>> PochakPostDataManager is currently reloading!!!!!!!")
                } else {
                    self?.postCollectionView.insertItems(at: newIndexPaths)
                }
                self?.isCurrentlyFetching = false
                self?.currentFetchingPage += 1;
            }
        }
    }
}

// MARK: - Extension : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate

extension PochakPostTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePostCollectionViewCell.identifier,
            for: indexPath) as? ProfilePostCollectionViewCell else {
            return UICollectionViewCell()
        }
        let postData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.setUpCellData(postData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat((collectionView.frame.width - 10) / 3)
        return CGSize(width: width, height: width * 4 / 3)
    }
    
    //  post 클릭 시 해당 post로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        postVC.receivedPostId = imageArray[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}

extension PochakPostTabmanViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (postCollectionView.contentOffset.y > (postCollectionView.contentSize.height - postCollectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setUpData()
            }
        }
    }
}
