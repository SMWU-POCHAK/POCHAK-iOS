//
//  TermsOfUseViewController.swift
//  pochak
//
//  Created by Seo Cindy on 5/14/24.
//

import UIKit

class TermsOfUseViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 네비게이션바 세팅
        /// Title
        self.navigationItem.title = "설정"
        /// Back Button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
