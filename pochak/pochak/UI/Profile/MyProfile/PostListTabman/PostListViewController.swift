//
//  PostListViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit
import Tabman
import Pageboy

class PostListViewController: TabmanViewController {

    // MARK: - Data
    
    private var viewControllers: [UIViewController] = [] // Tabbar로 넘길 VC 배열 선언
    var handle: String?

    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Tabman 사용
        /* 1. tab에 보여질 VC 추가 */
        if let firstVC = storyboard?.instantiateViewController(withIdentifier: "FirstPostTabmanVC") as? FirstPostTabmanViewController {
            viewControllers.append(firstVC)
            firstVC.receivedHandle = handle ?? ""
        }
        if let secondVC = storyboard?.instantiateViewController(withIdentifier: "SecondPostTabmanVC") as? SecondPostTabmanViewController {
            viewControllers.append(secondVC)
            secondVC.receivedHandle = handle ?? ""
        }
        self.dataSource = self

        /* 2. 바 생성 + tabbar 에 관한 디자인처리 */
        let bar = TMBar.ButtonBar()
        // 배경색
        bar.backgroundView.style = .clear
        // tab 밑 bar 색깔 & 크기
        bar.indicator.weight = .custom(value: 4)
        bar.indicator.tintColor = UIColor(named: "yellow00")
        // padding 설정
        bar.layout.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // center 정렬
        bar.layout.alignment = .centerDistributed
        // 배경색
        bar.backgroundView.style = .clear
        bar.backgroundColor = UIColor(named: "gray01")
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
}

// MARK: - Extension

// DataSource Extension
extension PostListViewController: PageboyViewControllerDataSource, TMBarDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 0)
    }
    
    // 팔로워 페이지 혹은 팔로잉 페이지인지에 따라 defualtPage 다르게 하기
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
           case 0:
            let item = TMBarItem(title: "POCHACKED")
            return item
           case 1:
            let item = TMBarItem(title: "POCHAK")
            return item
           default:
               let title = "Page \(index)"
              return TMBarItem(title: title)
           }
    }
}
