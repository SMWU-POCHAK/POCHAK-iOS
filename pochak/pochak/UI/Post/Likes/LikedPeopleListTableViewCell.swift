//
//  LikedPeopleListTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/21.
//

import UIKit

class LikedPeopleListTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    private var isFollowing: Bool = false  // 임시로 초깃값은 false -> 나중에 변경
    private var isFollowingColor: UIColor = UIColor(named: "gray03") ?? UIColor(hexCode: "FFB83A")
    private var isNotFollowingColor: UIColor = UIColor(named: "yellow00") ?? UIColor(hexCode: "C6CDD2")

    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 프로필 사진 둥글게
        profileImageView.layer.cornerRadius = 22.5
        
        // 팔로잉 상태 서버에서 확인 후 값 세팅
        //followingBtn.isSelected = isFollowing  // 팔로우 안된 상태
        
        followingBtn.setTitle("팔로우", for: .normal)
        followingBtn.setTitle("팔로잉", for: .selected)
        
        followingBtn.setTitleColor(UIColor.white, for: [.normal, .selected])
        
        //followingBtn.backgroundColor = isNotFollowingColor
        
        followingBtn.layer.cornerRadius = 4.97
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    @IBAction func followBtnDidTap(_ sender: Any) {
        // 언팔로우하기
        if followingBtn.isSelected {
            followingBtn.isSelected = false
            followingBtn.backgroundColor = isNotFollowingColor
        }
        // 팔로우하기
        else{
            followingBtn.isSelected = true
            followingBtn.backgroundColor = isFollowingColor
        }
    }
    
    // MARK: - Helper
    func setupData(_ likedUser: LikeMember){
        // 프로필 이미지
        if let profileImgStr = likedUser.profileImage {
            let url = URL(string: profileImgStr)
            // main thread에서 load할 경우 URL 로딩이 길면 화면이 멈춘다.
            // 이를 방지하기 위해 다른 thread에서 처리함.
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url!) {
                    if let image = UIImage(data: data) {
                        //UI 변경 작업은 main thread에서 해야함.
                        DispatchQueue.main.async {
                            self?.profileImageView.image = image
                        }
                    }
                }
            }
        }
        
        // 유저 핸들
        userHandleLabel.text = likedUser.handle
        
        // 유저 이름
        userNameLabel.text = likedUser.name
        
        // 팔로잉 버튼
        if likedUser.follow == nil {
            followingBtn.isHidden = true
        }
        else{
            if(likedUser.follow!){
                followingBtn.isSelected = true
            }
            else{
                followingBtn.isSelected = false
            }
            followingBtn.backgroundColor = likedUser.follow! ? self.isFollowingColor : self.isNotFollowingColor
        }
    }
    
}
