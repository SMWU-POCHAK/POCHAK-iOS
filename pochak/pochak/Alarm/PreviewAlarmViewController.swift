//
//  PreviewAlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 6/30/24.
//

import UIKit

class PreviewAlarmViewController : UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var taggedUsers: UILabel!
    @IBOutlet weak var pochakUser: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    
    var acceptButtonAction: (() -> Void)?
    var refuseButtonAction: (() -> Void)?

    var taggedUserHandle : [String]
    var pochakUserHandle : String?
    var profileImgUrl : String?
    var postImgUrl : String?
    var tagId : Int?
    
    @IBAction func acceptBtnTapped(_ sender: Any) {
        acceptButtonAction?()
    }

    @IBAction func refuseBtnTapped(_ sender: Any) {
        refuseButtonAction?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupAttribute()
        setupData()
    }

    private func setupAttribute(){
        profileImageView.layer.cornerRadius = 50/2
    }
    
    private func setupData(){
        self.postImageView.load(url: profileImgUrl)
//        for handle in taggedUserHandle {
//            if(handle == taggedUserHandle.last){
//                self.taggedUsers.text! != handle + " 님"
//            }
//            else{
//                self.taggedUsers.text! != handle + " 님 • "
//            }
//        }
        self.taggedUsers.text = self.taggedUserHandle +
        self.pochakUser.text = self.pochakUserHandle + "님이 포착"
        self.postImageView.load(url: postImgUrl)
    }
    
    func configure(with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            profileImageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                    self.profileImageView.contentMode = .scaleAspectFill

                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
    }
}
