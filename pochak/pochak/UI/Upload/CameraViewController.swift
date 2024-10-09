//
//  CameraViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/02.
//

import UIKit
import AVFoundation
import SwiftUI

final class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties
    
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var flashMode: AVCaptureDevice.FlashMode = .off
    private let hapticImpact = UIImpactFeedbackGenerator()
    private var currentZoomFactor: CGFloat = 1.0 {
        didSet {
            updateZoomLabel()
        }
    }
    private var lastScale: CGFloat = 1.0
    private let zoomRate: CGFloat = 0.9
    
    @Published var isCameraBusy = false
    @Published var isFlashOn = false
    
    private var currentCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    private var wideCamera: AVCaptureDevice?
    private var ultraWideInput: AVCaptureDeviceInput?
    private var wideInput: AVCaptureDeviceInput?
    
    
    // MARK: - Views
    
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var flashBtnBg: UIButton!
    @IBOutlet weak var flashbtn: UIButton!
    private var zoomLabel: UILabel = {
        let label = UILabel()
        label.text = "1x"
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var transitionView: UIView!
    private var currentPreviewLayer: AVCaptureVideoPreviewLayer?
    private var nextPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBAction func flashBtn(_ sender: Any) {
        switchFlash()
        print("flash")
    }
    
    @IBAction func capture(_ sender: Any) {
        if isCameraBusy == false {
            hapticImpact.impactOccurred()
            
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            photoSettings.flashMode = self.flashMode
            
            stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
            
            print("[Camera]: Photo's taken")
            print("[CameraViewModel]: Photo captured!")
        } else {
            print("[CameraViewModel]: Camera's busy.")
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "포착하기"
        
        setupZoomLabel()
        setupTransitionView()
        handlePinchGestureForZoom()
        handleTapGestrueToFocus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAndCheckPermissions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // MARK: - UI
    private func setupZoomLabel() {
        view.addSubview(zoomLabel)
        
        NSLayoutConstraint.activate([
            zoomLabel.centerYAnchor.constraint(equalTo: captureBtn.centerYAnchor),
            zoomLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            zoomLabel.widthAnchor.constraint(equalToConstant: 60),
            zoomLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        updateZoomLabel()
    }
    
    private func updateZoomLabel() {
        DispatchQueue.main.async {
            self.zoomLabel.text = String(format: "%.1fx", self.currentZoomFactor)
        }
    }
    
    private func setupTransitionView() {
        transitionView = UIView(frame: previewView.bounds)
        transitionView.backgroundColor = .clear
        transitionView.alpha = 0
        transitionView.translatesAutoresizingMaskIntoConstraints = false
        previewView.addSubview(transitionView)
        
        NSLayoutConstraint.activate([
            transitionView.topAnchor.constraint(equalTo: previewView.topAnchor),
            transitionView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
            transitionView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
            transitionView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor)
        ])
    }
    
    // MARK: - Functions
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            return
        }
        
        let uploadViewController = storyboard?.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController
        uploadViewController.receivedImage = image
        navigationController?.pushViewController(uploadViewController, animated: true)
    }
    
    private func requestAndCheckPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            break
        case .authorized:
            setUpCamera()
        default:
            print("Permission declined")
        }
    }
    
    private func switchFlash() {
        isFlashOn.toggle()
        flashMode = isFlashOn == true ? .on : .off
        
        let buttonImageName = isFlashOn ? "flashActiveBg" : "flashBg"
        flashBtnBg.setImage(UIImage(named: buttonImageName), for: .normal)
    }
    
    private func setUpCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            
            self.wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            self.ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
            
            guard let wideCamera = self.wideCamera, let ultraWideCamera = self.ultraWideCamera else {
                print("Error: Required cameras are not available")
                return
            }
            
            do {
                self.wideInput = try AVCaptureDeviceInput(device: wideCamera)
                self.ultraWideInput = try AVCaptureDeviceInput(device: ultraWideCamera)
                
                if self.captureSession.canAddInput(self.wideInput!) {
                    self.captureSession.addInput(self.wideInput!)
                    self.currentCamera = wideCamera
                }
                
                self.stillImageOutput = AVCapturePhotoOutput()
                if self.captureSession.canAddOutput(self.stillImageOutput) {
                    self.captureSession.addOutput(self.stillImageOutput)
                }
                
                if wideCamera.supportsSessionPreset(.photo) {
                    self.captureSession.sessionPreset = .photo
                }
                
                DispatchQueue.main.async {
                    self.setupLivePreview()
                }
                
                self.captureSession.startRunning()
                self.setInitialZoom()
            } catch {
                print("Error setting up camera: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupLivePreview() {
        self.currentPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.currentPreviewLayer?.videoGravity = .resizeAspectFill
        self.currentPreviewLayer?.connection?.videoOrientation = .portrait
        self.currentPreviewLayer?.frame = self.previewView.bounds
        
        if let currentPreviewLayer = self.currentPreviewLayer {
            self.previewView.layer.addSublayer(currentPreviewLayer)
        }
    }
    
    private func setupZoom(for device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = 1.0
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error.localizedDescription)")
        }
    }
    
    
    private func setInitialZoom() {
        guard let camera = self.currentCamera else { return }
        
        do {
            try camera.lockForConfiguration()
            camera.videoZoomFactor = 1.0
            self.currentZoomFactor = 1.0
            camera.unlockForConfiguration()
            
            DispatchQueue.main.async {
                self.updateZoomLabel()
            }
        } catch {
            print("Error setting initial zoom: \(error.localizedDescription)")
        }
    }
    
    private func switchToUltraWideCamera() {
        guard let ultraWideCamera = self.ultraWideCamera,
              let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        do {
            let newInput = try AVCaptureDeviceInput(device: ultraWideCamera)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
                currentCamera = ultraWideCamera
            }
        } catch {
            print("Error switching to ultra wide camera: \(error.localizedDescription)")
        }
        
        captureSession.commitConfiguration()
    }
    
    private func switchToCamera(_ newCamera: AVCaptureDevice) {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput,
              let newInput = (newCamera == wideCamera) ? wideInput : ultraWideInput else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.transitionView.alpha = 0.5
            })
        }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            currentCamera = newCamera
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.3, animations: {
                self.transitionView.alpha = 0
            })
        }
    }
    
    @objc func handlePinchToZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let wideCamera = self.wideCamera,
              let ultraWideCamera = self.ultraWideCamera else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(max(factor, 0.5), 6.0)
        }
        
        func update(scale factor: CGFloat) {
            do {
                if factor < 1.0 && currentCamera != ultraWideCamera {
                    switchToCamera(ultraWideCamera)
                } else if factor >= 1.0 && currentCamera != wideCamera {
                    switchToCamera(wideCamera)
                }
                
                try currentCamera?.lockForConfiguration()
                defer { currentCamera?.unlockForConfiguration() }
                
                let zoomFactor = (currentCamera == ultraWideCamera) ? factor * 2 : factor
                currentCamera?.videoZoomFactor = zoomFactor
                self.currentZoomFactor = factor
                
            } catch {
                print("Error setting zoom: \(error.localizedDescription)")
            }
        }
        
        var newScaleFactor = minMaxZoom(gesture.scale * currentZoomFactor)
        
        switch gesture.state {
        case .began:
            lastScale = currentZoomFactor
        case .changed:
            let delta = gesture.scale - 1.0
            if gesture.scale < 1.0 && currentZoomFactor > 1.0 {
                let fastZoomRate: CGFloat = 2
                newScaleFactor = minMaxZoom(lastScale + (delta * zoomRate * fastZoomRate))
            } else {
                newScaleFactor = minMaxZoom(lastScale + (delta * zoomRate))
            }
            update(scale: newScaleFactor)
        case .ended:
            newScaleFactor = currentZoomFactor
            lastScale = newScaleFactor
        default:
            break
        }
    }
}

extension CameraViewController {
    private func handlePinchGestureForZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchToZoom(_:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    private func handleTapGestrueToFocus() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        previewView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: previewView)
        focusOnPoint(touchPoint)
    }
    
    private func focusOnPoint(_ point: CGPoint) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                let focusPoint = CGPoint(x: point.x / previewView.bounds.size.width,
                                         y: point.y / previewView.bounds.size.height)
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                let exposurePoint = CGPoint(x: point.x / previewView.bounds.size.width,
                                            y: point.y / previewView.bounds.size.height)
                device.exposurePointOfInterest = exposurePoint
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            
            showFocusIndicator(at: point)
        } catch {
            print("Error setting focus: \(error.localizedDescription)")
        }
    }
    
    private func showFocusIndicator(at point: CGPoint) {
        let focusIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusIndicator.layer.borderWidth = 1.0
        focusIndicator.layer.borderColor = UIColor.yellow.cgColor
        focusIndicator.center = point
        focusIndicator.alpha = 0.0
        
        previewView.addSubview(focusIndicator)
        
        UIView.animate(withDuration: 0.3, animations: {
            focusIndicator.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
                focusIndicator.alpha = 0.0
            }) { _ in
                focusIndicator.removeFromSuperview()
            }
        }
    }
}
