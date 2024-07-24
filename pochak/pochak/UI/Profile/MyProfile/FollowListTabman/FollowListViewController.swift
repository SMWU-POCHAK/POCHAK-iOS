//
//  FollowListViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import Tabman
import Pageboy
import UIKit

class FollowListViewController: TabmanViewController {
    
   // MARK: - Data
    
    var viewControllers: [UIViewController] = []  // Tabbar로 넘길 VC 배열 선언
    var index: Int = 0
    var handle : String?
    var followerCount = UserDefaultsManager.getData(type: Int.self, forKey: .followerCount)
    var followingCount = UserDefaultsManager.getData(type: Int.self, forKey: .followingCount)

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 title 커스텀
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
//        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = handle ?? "handle not found"
//        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)]
        
        // Tabman 사용
        /* 1. tab에 보여질 VC 추가 */
        if let firstVC = storyboard?.instantiateViewController(withIdentifier: "FirstTabmanVC") as? FirstTabmanViewController {
            viewControllers.append(firstVC)
            firstVC.recievedHandle = handle ?? ""
        }
        if let secondVC = storyboard?.instantiateViewController(withIdentifier: "SecondTabmanVC") as? SecondTabmanViewController {
            viewControllers.append(secondVC)
            secondVC.recievedHandle = handle ?? ""
        }
        self.dataSource = self
        
        /* 2. 바 생성 + tabbar 에 관한 디자인처리 */
        let bar = TMBar.ButtonBar()
        // 배경색
        bar.backgroundView.style = .clear
        // tab 밑 bar 색깔 & 크기
        bar.indicator.weight = .custom(value: 2)
        bar.indicator.tintColor = UIColor(named: "yellow00")
        // padding 설정
        bar.layout.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // center 정렬
        bar.layout.alignment = .centerDistributed
        // tap 사이 간격
        bar.layout.contentMode = .fit //  버튼 화면에 딱 맞도록 구현
        // 선택된 tabbar tint 처리
        bar.buttons.customize { (button) in
            button.tintColor = UIColor(named: "gray04")
            button.selectedTintColor = UIColor(named: "navy00")
            button.font = UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.selectedFont =  UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        }
        
        /* 4. Baritem 등록 */
        addBar(bar, dataSource: self, at:.top)
    }
    // 뷰컨이 생길 때 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
//    // 뷰컨이 사라질 때 다시 동작
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = true
//    }
}
// MARK: - Extension

// DataSource Extension
extension FollowListViewController: PageboyViewControllerDataSource, TMBarDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        // index를 통해 처음에 보이는 탭을 설정할 수 있다.
         return .at(index: index)
    }
    
    // 팔로워 페이지 혹은 팔로잉 페이지인지에 따라 defualtPage 다르게 하기
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
           case 0:
//               return TMBarItem(title: "\(followerCount) 팔로워")
            return TMBarItem(title: "팔로워")
           case 1:
//               return TMBarItem(title: "\(followingCount) 팔로잉")
            return TMBarItem(title: "팔로잉")
           default:
               let title = "Page \(index)"
              return TMBarItem(title: title)
           }
    }
}