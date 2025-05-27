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
    
    private var zoomFactors: [CGFloat] = [1.0, 2.0, 3.0]
    private var hasUltraWideCamera: Bool = false
    private var buttons: [UIButton] = []
    private var selectedZoomFactor: CGFloat = 1.0
    private var isExpanded: Bool = false
    private var selectedBackgroundColor = UIColor(resource: .gray07).withAlphaComponent(0.6)
    private var unSelectedBackgroundColor = UIColor(resource: .gray05).withAlphaComponent(0.6)
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = unSelectedBackgroundColor
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.alignment = .fill
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
    
    func setUltraWideCameraAvailability(_ available: Bool) {
        if hasUltraWideCamera == available {
            return
        }
        
        hasUltraWideCamera = available
        
        if hasUltraWideCamera && !zoomFactors.contains(0.5) {
            zoomFactors.insert(0.5, at: 0)
        } else if !hasUltraWideCamera {
            zoomFactors.removeAll { $0 < 1.0 }
        }
        
        if !hasUltraWideCamera && selectedZoomFactor < 1.0 {
            selectedZoomFactor = 1.0
        }
        
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        updateContainerWidth(expanded: false)
        
        setupButtons()
        collapseView(animated: false)
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(28)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupButtons()
        collapseView(animated: false)
    }
    
    private func setupButtons() {
        zoomFactors.enumerated().forEach { index, zoomFactor in
            let button = UIButton()
            let zoomLabel = zoomFactor >= 1 ? String(format: "%.0f", zoomFactor) : String(format: "%.1f", zoomFactor).replacingOccurrences(of: "0.", with: ".")
            button.setTitle(zoomFactor == 1.0 ? "\(zoomLabel)x" : zoomLabel, for: .normal)
            button.titleLabel?.applyPochakFont(.captionMedium)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 14
            button.backgroundColor = zoomFactor == selectedZoomFactor ? selectedBackgroundColor : .clear
            button.addTarget(self, action: #selector(zoomFactorButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
            if zoomFactor != 1.0 {
                button.alpha = 0
            }
        }
        containerView.isUserInteractionEnabled = true
        stackView.isUserInteractionEnabled = true
    }
    
    @objc private func zoomFactorButtonTapped(_ sender: UIButton) {
        let zoomFactor = zoomFactors[sender.tag]
        
        if isExpanded {
            selectedZoomFactor = zoomFactor
            let zoomFactor = zoomFactors[sender.tag]
            delegate?.didSelectZoomFactor(zoomFactor)
            updateSelectedButtonStates()
            collapseView()
        } else {
            expandView()
        }
    }
    
    private func updateContainerWidth(expanded: Bool) {
        let buttonWidth: CGFloat = 28
        let spacing: CGFloat = 4
        
        let width: CGFloat
        if expanded {
            width = CGFloat(zoomFactors.count) * buttonWidth + CGFloat(zoomFactors.count - 1) * spacing
        } else {
            width = buttonWidth
        }
        
        containerView.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
    
    private func expandView() {
        isExpanded = true
        
        updateContainerWidth(expanded: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.buttons.forEach { button in
                button.isHidden = false
                button.alpha = 1
            }
            self.layoutIfNeeded()
        })
    }
    
    private func collapseView(animated: Bool = true) {
        isExpanded = false
        
        updateContainerWidth(expanded: false)
        
        let animation = {
            self.buttons.forEach { button in
                if let buttonTitle = button.title(for: .normal),
                   let index = self.zoomFactors.firstIndex(of: self.selectedZoomFactor) {
                    if button.tag == index {
                        button.alpha = 1
                        button.isHidden = false
                    } else {
                        button.alpha = 0
                        button.isHidden = true
                    }
                }
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
        let closestZoomFactor = findClosestZoomFactor(to: factor)
        selectedZoomFactor = factor
        
        let isCollapsed = buttons.filter({ !$0.isHidden }).count == 1
        
        
        if isCollapsed {
            buttons.forEach { button in
                if let index = zoomFactors.firstIndex(of: closestZoomFactor) {
                    if button.tag == index {
                        button.isHidden = false
                        button.alpha = 1
                        button.backgroundColor = selectedBackgroundColor
                    } else {
                        button.isHidden = true
                        button.alpha = 0
                    }
                }
            }
        }
        
        updateGestureButtonStates()
    }
    
    private func updateGestureButtonStates() {
        let closestZoomFactor = findClosestZoomFactor(to: selectedZoomFactor)
        
        buttons.forEach { button in
            if button.tag == zoomFactors.firstIndex(of: closestZoomFactor) {
                button.backgroundColor = selectedBackgroundColor
                let zoomFactorString = String(format: "%.1f", selectedZoomFactor).replacingOccurrences(of: "0.", with: ".")
                button.setTitle("\(zoomFactorString)x", for: .normal)
            } else {
                let originalZoomFactor = zoomFactors[button.tag]
                let zoomLabel = originalZoomFactor < 1.0 ? ".5" : String(format: "%.0f", originalZoomFactor)
                button.setTitle(zoomLabel, for: .normal)
                button.backgroundColor = .clear
            }
        }
    }
    
    private func updateSelectedButtonStates() {
        let closestZoomFactor = findClosestZoomFactor(to: selectedZoomFactor)
        
        buttons.forEach { button in
            if button.tag == zoomFactors.firstIndex(of: closestZoomFactor) {
                button.backgroundColor = selectedBackgroundColor
                let zoomFactorString = selectedZoomFactor >= 1 ? String(format: "%.0f", selectedZoomFactor) : String(format: "%.1f", selectedZoomFactor).replacingOccurrences(of: "0.", with: ".")
                button.setTitle("\(zoomFactorString)x", for: .normal)
            } else {
                let originalZoomFactor = zoomFactors[button.tag]
                let zoomLabel = originalZoomFactor < 1.0 ? ".5" : String(format: "%.0f", originalZoomFactor)
                button.setTitle(zoomLabel, for: .normal)
                button.backgroundColor = .clear
            }
        }
    }
    
    private func findClosestZoomFactor(to factor: CGFloat) -> CGFloat {
        guard zoomFactors.count > 1 else { return zoomFactors.first ?? 1.0 }
        
        if hasUltraWideCamera && factor < zoomFactors[1] {
            return zoomFactors[0] // 0.5x
        }
        
        for i in 1..<zoomFactors.count {
            if factor < zoomFactors[i] {
                return zoomFactors[i-1]
            }
        }
        
        return zoomFactors.last ?? 1.0
    }
}
