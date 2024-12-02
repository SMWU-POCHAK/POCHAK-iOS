//
//  FirstPostTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit
import Foundation

class PochakedPostTabmanViewController: UIViewController {
    
    // MARK: - Properties
    var receivedHandle: String?
    var imageArray: [ProfilePostList]! = []
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    private let minimumLineSpacing: CGFloat = 9
    private let minimumInterItemSpacing: CGFloat = 8
    private var isLastPage: Bool = false
    
    // MARK: - Views
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRefreshRequest), name: .didHitBottom, object: nil)
        currentFetchingPage = 0
        setUpData()
        setUpCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calculateCurentHeight()
    }
        
    // MARK: - Actions
    
    @objc private func didReceiveRefreshRequest(_ notification: Notification) {
        if ProfileDataSingleton.shared.currentTabIndex == 0 {
            setUpData()
        }
    }
    
    // MARK: - Functions
    
    func setUpData() {
        isCurrentlyFetching = true
        ProfileDataSingleton.shared.firstTabIsCurrentlyFetching = true
        let request = ProfileRetrievalRequest(page: currentFetchingPage)
        if let handle = receivedHandle {
            ProfileService.getProfile(handle: handle, request: request) { [weak self] data, failed in
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
                let startIndex = self?.imageArray.count
                let endIndex = startIndex! + newPosts.count
                let newIndexPaths = (startIndex!..<endIndex).map { IndexPath(item: $0, section: 0) }
                self?.imageArray.append(contentsOf: newPosts)
                self?.isLastPage = data.result.pageInfo.lastPage
                
                if self?.isLastPage == true {
                    ProfileDataSingleton.shared.firstTabIsLastPage = true
                }
                
                DispatchQueue.main.async {
                    if self?.currentFetchingPage == 0 {
                        self?.postCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    } else {
                        self?.postCollectionView.insertItems(at: newIndexPaths)
                    }
                    self?.isCurrentlyFetching = false
                    ProfileDataSingleton.shared.firstTabIsCurrentlyFetching = false
                    self?.currentFetchingPage += 1
                    self?.calculateCurentHeight()
                }
            }
        } else {
            print("No handle received")
        }
    }
    
    private func setUpCollectionView() {
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        postCollectionView.register(
            UINib(nibName: ProfilePostCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identifier)
        postCollectionView.isScrollEnabled = false
        postCollectionView.backgroundColor = .green
    }
    
    private func calculateCurentHeight() {
        DispatchQueue.main.async {
            if let flowLayout = self.postCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let delegateInsets = (self.collectionView(
                    self.postCollectionView,
                    layout: flowLayout,
                    insetForSectionAt: 0
                ))
                
                // UIEdgeInsets의 top, bottom 값 추출
                let topInset = delegateInsets.top
                let bottomInset = delegateInsets.bottom
                let contentHeight = self.postCollectionView.collectionViewLayout.collectionViewContentSize.height
                let totalHeight = contentHeight + topInset + bottomInset
                ProfileDataSingleton.shared.firstTabHeight = totalHeight
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extension : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate

extension PochakedPostTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        cell.setUpCellData(postData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInterItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("Inset method called")
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat((collectionView.frame.width - 20 * 2 - minimumInterItemSpacing * 2) / 3)
        return CGSize(width: width, height: width * 4 / 3)
    }
    
    // post 클릭 시 해당 post로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        postVC.receivedPostId = imageArray[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}
