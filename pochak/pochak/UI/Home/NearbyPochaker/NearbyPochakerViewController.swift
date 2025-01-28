//
//  NearbyPochakerViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/14/25.
//

import UIKit
import SnapKit
import CoreBluetooth

final class NearbyPochakerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let circle1Radius: CGFloat = 656
    private let circle2Radius: CGFloat = 484
    private let circle3Radius: CGFloat = 312
    private let circle4Radius: CGFloat = 148
    
    // MARK: - Views
    
    private let currentUserView: UIView = UIView()
    
    private let userProfileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "logo_full")
        view.clipsToBounds = true
        view.layer.cornerRadius = 60 / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private let userHandleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 13)
        label.text = "나"
        return label
    }()
    
    private lazy var circle1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFF6E7", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle1Radius / 2
        return view
    }()
    
    private lazy var circle2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFEED0", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle2Radius / 2
        return view
    }()
    
    private lazy var circle3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFE2AF", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle3Radius / 2
        return view
    }()
    
    private lazy var circle4: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFD489", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle4Radius / 2
        return view
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변 포착 친구를 찾고, 포착하세요!"
        label.font = UIFont(name: "Pretendard-Semibold", size: 16)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        self.navigationItem.title = "내 주변 포착"
        
        addViews()
        setupConstraints()
        
        BluetoothSerialManager.shared.delegate = self
        
        // TODO: 스캔 시작 포인트 수정해야 함
        // 뷰컨트롤러에 들어오면 스캔 시작
        BluetoothSerialManager.shared.setBluetoothModeAndStart(to: .scanningMode)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        BluetoothSerialManager.shared.setBluetoothModeAndStart(to: .advertisingMode)
    }
    
    // MARK: - Layout
    
    private func addViews() {
        currentUserView.addSubview(userProfileImageView)
        currentUserView.addSubview(userHandleLabel)
        
        view.addSubview(circle1)
        view.addSubview(circle2)
        view.addSubview(circle3)
        view.addSubview(circle4)
        view.addSubview(guideLabel)
        
        view.addSubview(currentUserView)
    }
    
    private func setupConstraints() {
        circle1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(28)
            make.width.height.equalTo(circle1Radius)
        }
        
        circle2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circle1.snp.top).inset((circle1Radius - circle2Radius) / 2)
            make.width.height.equalTo(circle2Radius)
        }
        
        circle3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circle2.snp.top).inset((circle2Radius - circle3Radius) / 2)
            make.width.height.equalTo(circle3Radius)
        }
        
        circle4.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circle3.snp.top).inset((circle3Radius - circle4Radius) / 2)
            make.width.height.equalTo(circle4Radius)
        }
        
        currentUserView.snp.makeConstraints { make in
            make.center.equalTo(circle1.snp.center)
        }
        
        userProfileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        userHandleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalTo(userProfileImageView.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
        }
        
        guideLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(70)
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    
    private func addPochakerView(handle: String) {
        let pochakerView = NearbyPochakerView(handle: handle)
        
        view.addSubview(pochakerView)
        
        pochakerView.snp.makeConstraints { make in
            make.top.equalTo(currentUserView.snp.bottom).offset(13)
            make.leading.equalTo(currentUserView.snp.trailing).offset(92)
        }
    }
}

// MARK: - Extension; BluetoothSerialDelegate

extension NearbyPochakerViewController: BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber?) {
        print("=== serial did discover peripheral ===")
        addPochakerView(handle: advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "알수없음")
//        LocalPushNotificationManager.shared.sendPushNotification(title: "👀 내 주변에 포차커가 있어요!",
//                                                             body: "지금 눌러서 포착하기",
//                                                             identifier: "POCHAK_NEARBY")
//        print("=======================================")
//        BluetoothSerialManager.shared.stopScan()
    }
}
