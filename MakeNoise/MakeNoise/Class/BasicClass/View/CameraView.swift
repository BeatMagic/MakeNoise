//
//  CameraView.swift
//  MakeNoise
//
//  Created by X Young. on 2018/9/27.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraView: UIView {
// MARK: - 相机相关属性
    /// 是否到本地 (保存)
    var isSaveTheFileToLibrary = true
    
    /// 画质 (中)
    var mediaQuality: CameraAttributes.MediaQuality = .medium {
        didSet {
            self.session.beginConfiguration()
            self.changeMediaQuality(mediaQuality)
            self.session.commitConfiguration()
            
        }
    }

    /// 哪个摄像头 (前置)
    var cameraPosition: CameraAttributes.CameraPosition = .front {
        didSet {
            self.sessionQueue.async {
                self.session.beginConfiguration()
                self.changeCameraPosion(self.cameraPosition)
                self.session.commitConfiguration()
            }
        }
    }

    /// 闪光灯模式 (关闭)
    var flashModel: CameraAttributes.FlashMode = .off {
        didSet {
            self.session.beginConfiguration()
            self.changeFlashModel(flashModel)
            self.session.commitConfiguration()
            
        }
    }
    
// MARK: - Private Property
    private var videoCompleteHandler: ((_ videoFileUrl: URL?, _ error: Error?) -> ())?
    
    private var cannotAccessTheCameraHandler:(() -> Void)?
    
    private var lastScale: CGFloat = 1.0
    
    /// 资源调度
    private lazy var session = AVCaptureSession()
    
    /// 输入设备
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    /// 输出影片文件
    private lazy var movieFileOutput: AVCaptureMovieFileOutput? = AVCaptureMovieFileOutput()
    
    /// 实时画面Layer
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
    
    /// 专属操作调度session的线程
    private lazy var sessionQueue: DispatchQueue = DispatchQueue.init(label: "sessionQueue")
    
    /// 前置输出
    private lazy var frontDeviceInput: AVCaptureDeviceInput? = self.deviceInput(forDevicePosition: .front)
    
    /// 后置输出
    private lazy var backDeviceInput: AVCaptureDeviceInput? = self.deviceInput(forDevicePosition: .back)
    
    /// 缩放手势
    private lazy var pinchGes: UIPinchGestureRecognizer = {
        let tmpPinch = UIPinchGestureRecognizer.init(target: self, action: #selector(self.handlePinGesture(pinGes:)))
        
        return tmpPinch
    }()
    
// MARK: - Initially
    init(frame: CGRect, musicKeyboard: UIView?) {
        super.init(frame: frame)
        
        self.setProperty()
        self.setUI()
        
        if let tmpMusicKeyboard = musicKeyboard {
            self.addSubview(tmpMusicKeyboard)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.previewLayer.frame = self.bounds
        
    }
    
    /// 回收时清除各种操作
    deinit {
        self.session.stopRunning()
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

extension CameraView {
    /// 设置属性
    func setProperty() -> Void {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(self.previewLayer)
        // 超出范围部分裁掉
        self.clipsToBounds = true
        
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapGesture(tapGes:)))
        self.addGestureRecognizer(tapGes)
        self.addGestureRecognizer(self.pinchGes)
    
        // 添加影片输出
        self.session.addOutput(self.movieFileOutput!)
        self.backgroundColor = UIColor.clear
    }
    
    /// 设置UI
    func setUI() -> Void {
        
    }
    
    /// 缩放事件
    @objc func handlePinGesture(pinGes: UIPinchGestureRecognizer) {
        var beginScale: CGFloat = 1.0
        
        switch pinGes.state {
        case .began:
            beginScale = pinGes.scale
            
        case .changed:
            if let device = videoDeviceInput?.device {
                do {
                    
                    // only when preset = photo is the videoMaxZoomFactor != 1.0
                    // and can zoom
                    let maxScale = min(20.0, device.activeFormat.videoMaxZoomFactor)
                    // do not change too fast
                    let tempScale = min(lastScale + 0.3*(pinGes.scale - beginScale), maxScale)
                    lastScale = max(1.0, tempScale)
                    
                    try device.lockForConfiguration()
                    device.videoZoomFactor = lastScale
                    device.unlockForConfiguration()
                } catch {
                    print("cannot lock ")
                }
            }
            
        default :
            break
        }
        
        
    }
    
    /// 点击事件
    @objc func handleTapGesture(tapGes: UITapGestureRecognizer) {
        let location = tapGes.location(in: tapGes.view)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        sessionQueue.async() {
            self.changeFocusModel(focusModel: .autoFocus, exposureModel: .autoExpose, atPoint: devicePoint, isMonitor: true)
            
        }
        
    }
    
    @objc func handleSubjectAreaChange(noti: NSNotification) {
        // reset to center (0.0---1.0)
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        // set false
        sessionQueue.async() {
            // set to continuous and do not monitor
            self.changeFocusModel(focusModel: .autoFocus, exposureModel: .autoExpose, atPoint: devicePoint, isMonitor: true)
        }
    }
    
}

extension CameraView {
    /// 改变成像质量
    private func changeMediaQuality(_ mediaQuality: CameraAttributes.MediaQuality) -> Void {
        let preset = mediaQuality.changeToAvPreset()
        
        if self.session.canSetSessionPreset(preset) {
            self.session.sessionPreset = preset
        }
        
    }
    
    /// 改变闪光灯模式
    private func changeFlashModel(_ flashModel: CameraAttributes.FlashMode) -> Void {
        let avFlashModel = flashModel.changeToAvFlashModel()
        
        if let trueVideoDevice = self.videoDeviceInput?.device {
            
            if trueVideoDevice.hasFlash && trueVideoDevice.isFlashModeSupported(avFlashModel) {
                
                do {
                    try trueVideoDevice.lockForConfiguration()
                    trueVideoDevice.flashMode = avFlashModel
                    trueVideoDevice.unlockForConfiguration()
                    
                } catch {
                    print("can not lock the device for configuration!! ---\(error)")
                    
                }
                
            }
            
        }
        
    }
    
    /// 切换摄像头
    private func changeCameraPosion(_ cameraPosion: CameraAttributes.CameraPosition) -> Void {
        if self.videoDeviceInput != nil {
            self.session.removeInput(self.videoDeviceInput!)
            
        }
        
        switch cameraPosion {
        case .back:
            self.videoDeviceInput = self.backDeviceInput
            
        case .front:
            self.videoDeviceInput = self.frontDeviceInput
            
        }
        
        if self.videoDeviceInput != nil && self.session.canAddInput(self.videoDeviceInput!) {
            self.session.addInput(self.videoDeviceInput!)
            
        }
        
    }
    
    /// 绑定需要的回调
    private func askForAccessDevice(withCompleteHandler completeHandler:((_ succeed: Bool) -> Void)?) {
        // 挂起线程到处理完为止
        self.sessionQueue.suspend()
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (succeed) in
            if succeed {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (succeed) in
                    completeHandler?(succeed)
                    // resume the queue
                    self.sessionQueue.resume()
                    
                })
                
            } else {
                completeHandler?(false)
                self.sessionQueue.resume()
                
            }
        })
    }
    
    /// 获取摄像头
    private func deviceInput(forDevicePosition position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        var deviceInput: AVCaptureDeviceInput? = nil
        for device in devices {
            if device.position == position {
                deviceInput = try? AVCaptureDeviceInput(device: device)
                break
            }
        }
        
        return deviceInput
    }
    
    /// 切换对焦
    private func changeFocusModel(focusModel: AVCaptureDevice.FocusMode,
                                  exposureModel: AVCaptureDevice.ExposureMode,
                                  atPoint: CGPoint,
                                  isMonitor: Bool) -> Void {
        
        if let device = self.videoDeviceInput?.device {
            
            do {
                // must lock it or it may causes crashing
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusModel) {
                    device.focusPointOfInterest = atPoint
                    device.focusMode = focusModel
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureModel) {
                    // only when setting the exposureMode after setting exposurePointOFInterest can be successful
                    device.exposurePointOfInterest = atPoint
                    device.exposureMode = exposureModel
                }
                // only when set it true can we receive the AVCaptureDeviceSubjectAreaDidChangeNotification
                device.isSubjectAreaChangeMonitoringEnabled = isMonitor
                device.unlockForConfiguration()
                
                
            } catch {
                print("cannot change the focusModel")
                
            }
            
        }
        
    }
    
    /// 添加声音设备
    private func addAudioInputDevice() {
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        do {
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            if self.session.canAddInput(audioDeviceInput) {
                self.session.addInput(audioDeviceInput)
                
            } else {
                print("can not add the audio inputDevice")
                
            }
            
        } catch {
            print("can not add create the audio input")
        }
    }
    
    /// 添加属性观察
    private func addObserver() {
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(self.handleSubjectAreaChange(noti:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput?.device)
        
    }
}

extension CameraView {
    public func setHandlerWhenCannotAccessTheCamera(handler: (() -> Void)?) {
        self.cannotAccessTheCameraHandler = handler
        
    }
    
    /// 自动切换闪光灯模式
    public func autoChangeFlashModel() -> Void {

        if let newFlashModel = CameraAttributes.FlashMode.init(rawValue: (self.flashModel.rawValue + 1) % 3) {
            
            self.flashModel = newFlashModel
        }
        
    }
    
    /// 自动切换摄像头
    public func autoChangeCameraPosition() -> Void {
        
        if let newCameraPosition = CameraAttributes.CameraPosition.init(rawValue: (self.cameraPosition.rawValue + 1) % 2) {
            
            self.cameraPosition = newCameraPosition
        }
        
    }
    
    /// 自动切换成像质量
    public func autoChangeMediaQuality() -> Void {
        if let newMediaQuality = CameraAttributes.MediaQuality.init(rawValue: ( self.mediaQuality.rawValue + 1) % 3 ) {
            
            self.mediaQuality = newMediaQuality
        }
    }
    
    /// 开始捕捉视频
    public func startCapturingVideo() -> Bool {

        self.session.beginConfiguration()
        if !self.hasCamera() {
            return false
            
        }
        
        let connection = self.movieFileOutput?.connection(with: AVMediaType.video)
        connection?.videoOrientation = (self.previewLayer.connection?.videoOrientation)!
        self.session.commitConfiguration()
        
        let tempFileName = "\(ProcessInfo().globallyUniqueString).mov"
        let tempFilePath = NSTemporaryDirectory() + "/" + tempFileName
        let tempVideoURL = URL.init(fileURLWithPath: tempFilePath)
        
        self.movieFileOutput?.startRecording(to: tempVideoURL, recordingDelegate: self)
        
        return true
    }
    
    /// 准备相机
    public func prepareCamera() -> Bool {
        
        
        if !hasCamera() {
            return false
        }
        
        // do not block the main queue
        sessionQueue.async() {
            
            self.askForAccessDevice(withCompleteHandler: { (succeed) in
                if !succeed {
                    DispatchQueue.main.async {
                        self.cannotAccessTheCameraHandler?()
                    }
                    
                    return
                }
                
                // add inputs and outputs
                self.session.beginConfiguration()
                
                // this will add current device
                self.cameraPosition = .front
                // setting flashModel
                self.flashModel = .auto
                // setting mediaQuality
                self.mediaQuality = .medium
                // addAudioInputDevice
                self.addAudioInputDevice()
                self.session.commitConfiguration()
                self.addObserver()
                self.session.startRunning()
                
            })
        }
        
        return true
    }
    
    public func stopCapturingVideo(withHandler handler: @escaping (_ videoUrl: URL?, _ error: Error?) -> ()) {
        videoCompleteHandler = handler
        movieFileOutput?.stopRecording()
    }
    
}

extension CameraView {
    private func hasCamera() -> Bool {
        if frontDeviceInput != nil || backDeviceInput != nil {
            return true
            
        } else {
            return false
            
        }
    }
}

extension CameraView: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        var success = true
        
        if error != nil {// sometimes there may be error but the video is caputed successfully
            success = (error as! CustomNSError).errorUserInfo[AVErrorRecordingSuccessfullyFinishedKey] as! Bool
            
        }
        
        if (success) {
            if isSaveTheFileToLibrary {
                
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized {
                        
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                            
                        }, completionHandler: {[unowned self] (succeed, error) in
                            if succeed {
                                self.videoCompleteHandler?(outputFileURL, error)
                                
                            } else {
                                self.videoCompleteHandler?(outputFileURL, error)
                            }
                            do {
                                try FileManager.default.removeItem(at: outputFileURL)
                            } catch {
                                print("can not save video to alblum")
                            }
                        })
                    }
                })
                
            } else {
                self.videoCompleteHandler?(outputFileURL, error)
                
            }
        }
    }
    
    
}


