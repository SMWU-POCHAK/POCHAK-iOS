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
        
        handlePinchGestureForZoom()
        
        setupZoomLabel()
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
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                
                let photoSettings = AVCapturePhotoSettings()
                photoSettings.isHighResolutionPhotoEnabled = false
                
                if backCamera.supportsSessionPreset(.photo) {
                    self.captureSession.sessionPreset = .photo
                }
                
                self.stillImageOutput = AVCapturePhotoOutput()
                
                if self.captureSession.canAddInput(input) && self.captureSession.canAddOutput(self.stillImageOutput) {
                    self.captureSession.addInput(input)
                    self.captureSession.addOutput(self.stillImageOutput)
                    
                    DispatchQueue.main.async {
                        self.setupLivePreview()
                    }
                    
                    self.captureSession.startRunning()
                }
            } catch let error {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
        }
    }
    
    private func setupLivePreview() {
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        // previewView의 bounds에 맞게 frame 설정
        self.videoPreviewLayer.frame = self.previewView.bounds
        
        // previewView의 서브레이어로 추가
        self.previewView.layer.addSublayer(self.videoPreviewLayer)
    }
    
    private func handlePinchGestureForZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchToZoom(_:)))
        view.addGestureRecognizer(pinchGesture)
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
    
    @objc func handlePinchToZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(max(factor, 1.0), 6.0)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
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
            if gesture.scale < 1.0 {
                let fastZoomRate: CGFloat = 2
                let newScaleFactor = minMaxZoom(lastScale + (delta * zoomRate * fastZoomRate))
                update(scale: newScaleFactor)
            } else {
                let newScaleFactor = minMaxZoom(lastScale + (delta * zoomRate))
                update(scale: newScaleFactor)
            }
        case .ended:
            newScaleFactor = currentZoomFactor
            lastScale = newScaleFactor
        default:
            break
        }
    }
}
