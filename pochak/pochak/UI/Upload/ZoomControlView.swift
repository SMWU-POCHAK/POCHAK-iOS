//
//  ZoomControlView.swift
//  pochak
//
//  Created by Haru on 12/30/24.
//

import UIKit
import SnapKit

protocol ZoomControlViewDelegate: AnyObject {
    func didSelectZoomFactor(_ factor: CGFloat)
}

class ZoomControlView: UIView {
    weak var delegate: ZoomControlViewDelegate?
    
    private let speeds: [String] = [".5", "1x", "2", "3"]
    private var zoomFactors: [CGFloat] = [0.5, 1.0, 2.0, 3.0]
    private var buttons: [UIButton] = []
    private var selectedSpeed: String = "1x"
    private var isExpanded: Bool = false
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 14
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupButtons()
        collapseView(animated: false)
    }
    
    private func setupButtons() {
        speeds.enumerated().forEach { index, speed in
            let button = UIButton()
            button.setTitle(speed, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = speed == selectedSpeed ? .black.withAlphaComponent(0.6) : .black.withAlphaComponent(0.2)
            button.layer.cornerRadius = 14
            button.addTarget(self, action: #selector(speedButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            buttons.append(button)
            stackView.addArrangedSubview(button)
            if speed != "1x" {
                button.alpha = 0
            }
        }
        containerView.isUserInteractionEnabled = true
        stackView.isUserInteractionEnabled = true
    }
    
    @objc private func speedButtonTapped(_ sender: UIButton) {
        guard let speed = sender.title(for: .normal) else { return }
        
        if isExpanded {
            selectedSpeed = speed
            let zoomFactor = zoomFactors[sender.tag]
            delegate?.didSelectZoomFactor(zoomFactor)
            updateButtonStates()
            collapseView()
        } else {
            expandView()
        }
    }
    
    private func expandView() {
        isExpanded = true
        UIView.animate(withDuration: 0.3, animations: {
            self.buttons.forEach { button in
                button.isHidden = false
                button.alpha = 1
            }
            
            self.containerView.snp.updateConstraints { make in
                make.width.equalTo(124)
            }
            self.layoutIfNeeded()
        })
    }
    
    private func collapseView(animated: Bool = true) {
        isExpanded = false
        let animation = {
            self.buttons.forEach { button in
                if button.title(for: .normal) != self.selectedSpeed {
                    button.alpha = 0
                    button.isHidden = true
                }
            }
            
            self.containerView.snp.updateConstraints { make in
                make.width.equalTo(28)
            }
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: animation)
        } else {
            animation()
        }
    }
    
    func updateSelectedZoom(factor: CGFloat) {
        let speedString: String
        switch factor {
        case 0.5:
            speedString = ".5"
        case 1.0:
            speedString = "1x"
        case 2.0:
            speedString = "2"
        case 3.0:
            speedString = "3"
        default:
            if factor < 0.75 {
                speedString = ".5"
            } else if factor < 1.5 {
                speedString = "1x"
            } else if factor < 2.5 {
                speedString = "2"
            } else {
                speedString = "3"
            }
        }
        
        if speedString != selectedSpeed {
            selectedSpeed = speedString
            
            let isCollapsed = buttons.filter({ !$0.isHidden }).count == 1
            
            if isCollapsed {
                updateButtonStates()
                buttons.forEach { button in
                    if button.title(for: .normal) == speedString {
                        button.isHidden = false
                        button.alpha = 1
                        button.backgroundColor = .black.withAlphaComponent(0.6)
                    } else {
                        button.isHidden = true
                        button.alpha = 0
                    }
                }
            } else {
                updateButtonStates()
            }
        }
    }
    
    private func updateButtonStates() {
        buttons.forEach { button in
            button.backgroundColor = button.title(for: .normal) == selectedSpeed ? .black.withAlphaComponent(0.6) : .black.withAlphaComponent(0.2)
        }
    }
}
