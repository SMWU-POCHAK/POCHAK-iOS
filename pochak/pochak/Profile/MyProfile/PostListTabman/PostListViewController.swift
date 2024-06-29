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

    // Tabbar로 넘길 VC 배열 선언
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tabman 사용
        /* 1. tab에 보여질 VC 추가 */
        if let firstVC = storyboard?.instantiateViewController(withIdentifier: "FirstPostTabmanVC") as? FirstPostTabmanViewController {
            viewControllers.append(firstVC)
        }
        if let secondVC = storyboard?.instantiateViewController(withIdentifier: "SecondPostTabmanVC") as? SecondPostTabmanViewController {
            viewControllers.append(secondVC)
        }
        self.dataSource = self

        /* 2. 바 생성 + tabbar 에 관한 디자인처리 */
        // 바 생성 + tabbar 에 관한 디자인처리를 여기서 하면 된다.
        let bar = TMBar.ButtonBar()
        //        bar.layout.transitionStyle = .none
        
        // 배경색
        bar.backgroundView.style = .clear
        
        // tab 밑 bar 색깔 & 크기
        bar.indicator.weight = .custom(value: 4)
        bar.indicator.tintColor = UIColor(named: "yellow00")
        
        // padding 설정
        bar.layout.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        // tap center
        bar.layout.alignment = .centerDistributed
        
        // 배경색
        bar.backgroundView.style = .clear
        bar.backgroundColor = UIColor(named: "gray01")
        
        // tap 사이 간격
        bar.layout.contentMode = .fit //  버튼 화면에 딱 맞도록 구현
        //        bar.layout.interButtonSpacing = 20
        
        // tap 선택 / 미선택
        bar.buttons.customize { (button) in
            button.tintColor = UIColor(named: "gray04")
            button.selectedTintColor = UIColor(named: "navy00")
            button.font = UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.selectedFont =  UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        }
//        let bar = TMBar.TabBar()
//        // 배경색
//        bar.backgroundView.style = .clear
//        bar.backgroundColor = UIColor(named: "navy00")
//        bar.layout.alignment = .centerDistributed
        /* Baritem 등록 */
        addBar(bar, dataSource: self, at:.top)
        
        
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
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
    
    // 팔로워 / 팔로잉에 따라 defualtPage 다르게 하기
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
           case 0:
            let item = TMBarItem(title: "POCHACKED")
            item.image = UIImage(named: "pochaked_selected")
            return item
           case 1:
            let item = TMBarItem(title: "POCHAK")
            item.image = UIImage(named: "pochak_selected")
            return item
           default:
               let title = "Page \(index)"
              return TMBarItem(title: title)
           }
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
