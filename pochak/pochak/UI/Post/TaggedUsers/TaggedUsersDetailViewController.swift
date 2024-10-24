//
//  TaggedUsersDetailViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/5/24.
//

import UIKit

final class TaggedUsersDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var tagList: [TaggedMember]?
    var goToOtherProfileVC: ((String) -> Void)?

    // MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
    }
        
    // MARK: - Funtions
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: TaggedUsersTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: TaggedUsersTableViewCell.identifier)
    }
}

// MARK: - Extension: UITableView

extension TaggedUsersDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaggedUsersTableViewCell.identifier, for: indexPath) as? TaggedUsersTableViewCell else { return UITableViewCell() }
        cell.configure(tagData: tagList![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        goToOtherProfileVC!(tagList![indexPath.row].handle)
    }
}
