//
//  CameraViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/02.
//

import UIKit
import AVFoundation
import SwiftUI

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var previewView: UIView!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoData = Data(count: 0)
    
    @IBOutlet weak var flashBtnBg: UIButton!
    
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    let hapticImpact = UIImpactFeedbackGenerator()
    
    var currentZoomFactor: CGFloat = 1.0
    var lastScale: CGFloat = 1.0
    
    @Published var recentImage: UIImage?
    @Published var isCameraBusy = false
    
    @Published var showPreview = false
    @Published var shutterEffect = false
    @Published var isFlashOn = false
    
    @IBOutlet weak var flashbtn: UIButton!
    
    @IBAction func flashBtn(_ sender: Any) {
        switchFlash()
        print("flash")
    }
    
    @IBAction func captureBtn(_ sender: Any) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-bold", size: 20)!]
        self.navigationItem.title = "포착하기"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAndCheckPermissions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            return
        }
        
        let uploadViewController = storyboard?.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController
        uploadViewController.receivedImage = image
        navigationController?.pushViewController(uploadViewController, animated: true)
    }
    
    func requestAndCheckPermissions() {
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
    
    func switchFlash() {
        isFlashOn.toggle()
        flashMode = isFlashOn == true ? .on : .off
        
        let buttonImageName = isFlashOn ? "flashActiveBg" : "flashBg"
        flashBtnBg.setImage(UIImage(named: buttonImageName), for: .normal)
    }
    
    func setUpCamera() {
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

                    // 라이브 프리뷰 설정을 메인 스레드에서 호출
                    DispatchQueue.main.async {
                        self.setupLivePreview()
                    }

                    // captureSession.startRunning()을 백그라운드 스레드에서 호출
                    self.captureSession.startRunning()
                }
            } catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
        }
    }

    func setupLivePreview() {
        DispatchQueue.main.async { // 메인 스레드에서 실행되어야 함
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer.videoGravity = .resizeAspectFill
            self.videoPreviewLayer.connection?.videoOrientation = .portrait
            
            // previewView의 bounds에 맞게 frame 설정
            self.videoPreviewLayer.frame = self.previewView.bounds
            
            // previewView의 서브레이어로 추가
            self.previewView.layer.addSublayer(self.videoPreviewLayer)
        }
    }
}
