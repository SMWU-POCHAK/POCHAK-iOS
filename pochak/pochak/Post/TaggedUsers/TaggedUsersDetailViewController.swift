//
//  TaggedUsersDetailViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/5/24.
//

import UIKit

class TaggedUsersDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var tagList: [TaggedMember]?

    // MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
    }
    
    // MARK: - Actions
    
    // MARK: - Funtions
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: TaggedUsersTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: TaggedUsersTableViewCell.identifier)
    }
}


// MARK: - Extension; UITableView

extension TaggedUsersDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaggedUsersTableViewCell.identifier, for: indexPath) as? TaggedUsersTableViewCell else { return UITableViewCell() }
        cell.configure(tagData: tagList![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}
