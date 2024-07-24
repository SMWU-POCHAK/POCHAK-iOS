//
//  ReportTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

class ReportTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReportTableViewCell"
    
    var reportType: ReportType?

    // MARK: - Views
    
    @IBOutlet weak var reportReasonLabel: UILabel!
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func configure(reportType: ReportType){
        self.reportType = reportType
        self.reportReasonLabel.text = ReportType.getReasonForType(reportType)
    }
    
}
