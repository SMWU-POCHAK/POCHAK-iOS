//
//  TaggedUsersTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/5/24.
//

import UIKit

class TaggedUsersTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TaggedUsersTableViewCell"
    
    // MARK: - Views
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func configure(){
        
    }
}
