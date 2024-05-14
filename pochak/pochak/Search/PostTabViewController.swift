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
    
    let searchBar = UISearchBar()
    
    private var postTabDataResponse: PostTabDataResponse!
    private var postTabDataResult: PostTabDataResult!
    private var postList: [PostTabDataPostList]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        
        setupCollectionView()
        setUpSearchController()
        
        setupData()
   // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear search bar text and resign first responder when returning to this page
        self.searchBar.resignFirstResponder()
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
        PostTabDataService.shared.recommandGet(){
            response in
                switch response {
                case .success(let data):
                    print("success")
                    print(data)
                    self.postTabDataResponse = data as? PostTabDataResponse
                    self.postTabDataResult = self.postTabDataResponse.result
                    print(self.postTabDataResult!)
                    self.postList = self.postTabDataResult.postList
                    print(self.postList)
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
    
    private func setUpSearchController() {
        self.searchBar.placeholder = "Search User"
        self.searchBar.delegate = self
        self.navigationItem.titleView = searchBar

   }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // 최근 검색어 화면으로 전환
        let storyboard = UIStoryboard(name:"PostTab", bundle: nil)
        let recentSearchVC = storyboard.instantiateViewController(withIdentifier: "RecentSearchVC") as! RecentSearchViewController
        self.navigationController?.pushViewController(recentSearchVC, animated: false)
        // 편집 모드를 시작하려면 true를 반환해야 합니다.
        return true
    }
    
}


//MARK: - 포스트 collectionView
extension PostTabViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return max(0,(postList.count)-2)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패")
            }
            // 이미지 설정
            if(!postList.isEmpty){
                cell.configure(with: postList[indexPath.item].postImage)
            }
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else{
                fatalError("셀 타입 캐스팅 실패2")
            }
            // 이미지 설정
            if(!postList.isEmpty){
                cell.configure(with: postList[indexPath.item+2].postImage)
            }
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        switch section {
        case 0:
            print("view post btn tapped")
            
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
                else { return }
            
            postVC.receivedPostId = postList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
            
            
        default:
            print("view post btn tapped")
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
                else { return }
            
            postVC.receivedPostId = postList[indexPath.item+2].postId
            self.navigationController?.pushViewController(postVC, animated: true)
            
        }
    }
}

        
extension PostTabViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
            
        case 0:
            return 0
        default:
            return 5
        }
    }

        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.5, left: 24, bottom: 2.5, right: 24)
        }
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
            case 0:
                return 6
            default:
                return 5
            }
        }

            
    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 54) / 2 // 첫 번째 섹션의 셀 너비
        let height = width * 4 / 3 // 셀의 가로:세로 비율
        
        if indexPath.section == 0 {
            return CGSize(width: width, height: height) // 첫 번째 섹션의 셀 크기
        } else {
            let secWidth = (collectionView.frame.width - 58) / 3 // 두 번째 섹션의 셀 너비
            let secHeight = secWidth * 4 / 3 // 셀의 가로:세로 비율
            return CGSize(width: secWidth, height: secHeight) // 두 번째 섹션의 셀 크기
        }
    }
}
