//
//  PostLikesViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/20.
//

import UIKit

class PostLikesViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    public var postId: Int!
    public var postOwnerHandle: String!
    
    private var likeUsersDataResponse: LikedUsersDataResponse!
    private var likedUserDataResult: LikedUserDataResult!
    private var likedUsers: [LikeMember]!
    
    // MARK: - Lifecycle
//    override func loadView() {
//        LikedUsersDataService.shared.getLikedUsers(postId) {(response) in
//            // NetworkResult형 enum으로 분기 처리
//            switch(response){
//            case .success(let likedUsersData):
//                self.likeUsersDataResponse = likedUsersData as? LikedUsersDataResponse
//                self.likedUsers = self.likeUsersDataResponse.result.likedUsers
//                self.initUI()
//                //print(self.likedUsers)
//            case .requestErr(let message):
//                print("requestErr", message)
//            case .pathErr:
//                print("pathErr")
//            case .serverErr:
//                print("serveErr")
//            case .networkFail:
//                print("networkFail")
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LikedUsersDataService.shared.getLikedUsers(postId) {(response) in
            // NetworkResult형 enum으로 분기 처리
            switch(response){
            case .success(let likedUsersData):
                self.likeUsersDataResponse = likedUsersData as? LikedUsersDataResponse
                self.likedUsers = self.likeUsersDataResponse.result.likeMembersList
                self.initUI()
                //print(self.likedUsers)
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serveErr")
            case .networkFail:
                print("networkFail")
            }
        }
        
//        // tableView의 프로토콜
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none  // cell 간 구분선 스타일

        // 셀 등록
        let nib = UINib(nibName: "LikedPeopleListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "LikedPeopleListTableViewCell")
    }
    
    private func initUI(){
        // tableView의 프로토콜
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none  // cell 간 구분선 스타일
        
        // title 내용 설정
        titleLabel.text = postOwnerHandle+" 님의 게시물을 좋아하는 사람"
    }

}

// MARK: - Extension
extension PostLikesViewController: UITableViewDelegate, UITableViewDataSource {
    // 한 섹션의 몇 개의 열
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedUsers.count
    }
    
    // 어떤 셀
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LikedPeopleListTableViewCell", for: indexPath) as? LikedPeopleListTableViewCell else { return UITableViewCell() }
        
        if let cellData = self.likedUsers{
            cell.setupData(cellData[indexPath.row])
        }
        
        return cell
    }
    
    
}
