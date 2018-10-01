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

import Vision
import Upsurge

class CameraView: UIView {
// MARK: - 相机相关属性
    /// 是否到本地 (保存)
    var isSaveTheFileToLibrary = true
    
    let model = MobileOpenPose()
    let ImageWidth = 368
    let ImageHeight = 368
    lazy var classificationRequest: [VNRequest] = {
        do {
            let model = try VNCoreMLModel(for: self.model.model)
            let classificationRequest = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
            return [ classificationRequest ]
        } catch {
            fatalError("Can't load Vision ML model: \(error)")
        }
    }()
    
    var imageView: UIImageView = UIImageView.init(
        frame: CGRect.init(x: 0, y: 0, width: ToolClass.getScreenWidth(), height: ToolClass.getScreenHeight())
    )
    
    /// 画质 (中)
    var mediaQuality: CameraAttributes.MediaQuality = .medium {
        didSet {
            self.session.beginConfiguration()
            self.changeMediaQuality(mediaQuality)
            self.session.sessionPreset = AVCaptureSession.Preset.cif352x288
            videoConnection = videoDataOutput.connection(with: .video)
            
            videoConnection!.videoOrientation = .portrait
//            videoConnection!.videoOrientation = (self.previewLayer.connection?.videoOrientation)!
            
            audioConnection = audioDataOutput.connection(with: .audio)
            self.session.commitConfiguration()
            
        }
    }

    /// 哪个摄像头 (前置)
    var cameraPosition: CameraAttributes.CameraPosition = .front {
        didSet {
            self.sessionQueue.async {
                self.session.beginConfiguration()
                self.changeCameraPosion(self.cameraPosition)
                self.videoConnection?.videoOrientation = .portrait
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
    
    let musicKeyboard: OperateKeysView!

    
// MARK: - Private Property
    private var videoCompleteHandler: ((_ videoFileUrl: URL?, _ error: Error?) -> ())?
    
    private var cannotAccessTheCameraHandler:(() -> Void)?
    
    private var lastScale: CGFloat = 1.0
    
// MARK: - 调度
    /// 资源调度
    private let session = AVCaptureSession()
    
    /// session的线程
    private let sessionQueue = DispatchQueue.init(label: "sessionQueue")
    
    /// 视频线程
    private let videoDataOutputQueue = DispatchQueue.init(label: "videoDataOutputQueue")
    
    /// 音频线程
    private let audioDataOutputQueue = DispatchQueue.init(label: "audioDataOutputQueue")
    
    /// 写入线程
    private let writeFileQueue = DispatchQueue.init(label: "writeFileQueue")
    
    
// MARK: - 视频
    /// 输入
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    /// 输出
    private var videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
    private var videoConnection: AVCaptureConnection?

    
// MARK: - 音频
    /// 输入
    private var audioInput: AVCaptureDeviceInput?
    
    /// 输出
    private var audioDataOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    
    /// 链接
    private var audioConnection: AVCaptureConnection?
    
// MARK: - 保存
    var assetWriter: AVAssetWriter?
    var videoWriterInput: AVAssetWriterInput = {
        let tmpVideoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: CameraView.getVideoSetting())
        tmpVideoWriterInput.expectsMediaDataInRealTime = true
//        tmpVideoWriterInput.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        return tmpVideoWriterInput
    }()
    var audioWriterInput: AVAssetWriterInput?
    
// MARK: - 文件目录
    var tmpFileURL: URL?

// MARK: - 实时画面Layer
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
    
    
    
    
// MARK: - Init
    init(frame: CGRect, musicKeyboard: OperateKeysView) {
        self.musicKeyboard = musicKeyboard
            
        super.init(frame: frame)
        
        self.setProperty()
        self.setUI()
        
        self.addSubview(self.musicKeyboard)
        
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
    
        // 添加影片输出
        self.backgroundColor = UIColor.clear
        
        // this will add current device
        self.cameraPosition = .front
        
        self.videoDataOutput = {
            let tmpOutput = AVCaptureVideoDataOutput.init()
            
            tmpOutput.alwaysDiscardsLateVideoFrames = true
            tmpOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber.init(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            tmpOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
            
            if self.session.canAddOutput(tmpOutput) {
                self.session.addOutput(tmpOutput)
            }
            
            return tmpOutput
        }()
        
        self.audioDataOutput = {
            let tmpOutput = AVCaptureAudioDataOutput.init()
            tmpOutput.setSampleBufferDelegate(self, queue: self.audioDataOutputQueue)
            if self.session.canAddOutput(tmpOutput) {
                self.session.addOutput(tmpOutput)
            }
            
            return tmpOutput
        }()
        
        
        
        self.audioInput = {
            let audioCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            let tmpAudioInput = try! AVCaptureDeviceInput.init(device: audioCaptureDevice!)
            
            if self.session.canAddInput(tmpAudioInput) {
                self.session.addInput(tmpAudioInput)
            }
            
            return tmpAudioInput
        }()
        
    }
    
    /// 设置UI
    func setUI() -> Void {
        self.addSubview(self.imageView)
        
        //self.imageView.backgroundColor = UIColor.blue
        //self.imageView.alpha = 0.3
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

// MARK: - 各种代理
extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        //print("获取帧")
        
//        objc_sync_enter(self)
        if let assetWriter = assetWriter {
            if assetWriter.status != .writing && assetWriter.status != .unknown {
                return
            }
        }
        if let assetWriter = assetWriter, assetWriter.status == .unknown {
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        }
        if connection == self.videoConnection {
            videoDataOutputQueue.async {
                if  self.videoWriterInput.isReadyForMoreMediaData {
                    self.videoWriterInput.append(sampleBuffer)
                }
            }
        }
        else if connection == self.audioConnection {
            audioDataOutputQueue.async {
                if let audioWriterInput = self.audioWriterInput, audioWriterInput.isReadyForMoreMediaData {
                    audioWriterInput.append(sampleBuffer)
                }
            }
        }
//        objc_sync_exit(self)
        
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var ciImage: CIImage
        
        if cameraPosition == .front {
            let tmpCiImage = CIImage(cvImageBuffer: imageBuffer)
            let transform = CGAffineTransform(scaleX: -1, y: 1)
            
//            let obj = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            
            ciImage = tmpCiImage.transformed(by: transform)
            
            
        }else {
            
            ciImage = CIImage(cvImageBuffer: imageBuffer)
        }
        
        
        
        guard let pixelBuffer = UIImage(ciImage: ciImage).resize(to: CGSize(width: ImageWidth,height: ImageHeight)).pixelBuffer() else { return }
        
        var requestOptions:[VNImageOption: Any] = [:]
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.classificationRequest)
            
            
        } catch {
            print(error)
        }

    }
    
    
}

// MARK: - 录制保存相关
extension CameraView {
    
    /// 准备开始记录
    func startRecording() -> Void {
        let tempFilePath = NSTemporaryDirectory() + "tmp" + "\(ProcessInfo().globallyUniqueString).mp4"
        self.tmpFileURL = URL.init(fileURLWithPath: tempFilePath)
        
        do {
            assetWriter = try! AVAssetWriter(outputURL: tmpFileURL!, fileType: AVFileType.mp4)
            if assetWriter!.canAdd(videoWriterInput) {
                assetWriter!.add(videoWriterInput)
            }
            audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: CameraView.getAudioSetting())
            audioWriterInput?.expectsMediaDataInRealTime = true
            if assetWriter!.canAdd(audioWriterInput!) {
                assetWriter!.add(audioWriterInput!)
            }
            
            assetWriter!.startWriting()
        }
        
        
    }
    
    
    func endRecording() {
        if let assetWriter = self.assetWriter {
            
            videoWriterInput.markAsFinished()
            if let audioWriterInput = audioWriterInput {
                audioWriterInput.markAsFinished()
            }

            assetWriter.finishWriting(completionHandler: {
                
                if self.isSaveTheFileToLibrary {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        if status == PHAuthorizationStatus.authorized {
                            
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.tmpFileURL!)
                                
                            }, completionHandler: {[unowned self] (succeed, error) in
                                if succeed {
                                    self.videoCompleteHandler?(self.tmpFileURL!, error)
                                    
                                } else {
                                    self.videoCompleteHandler?(self.tmpFileURL!, error)
                                }
                                do {
                                    try FileManager.default.removeItem(at: self.tmpFileURL!)
                                } catch {
                                    print("can not save video to alblum")
                                }
                            })
                        }
                    })
                    
                }
                
            })
            
        }
        
    }
    
}

// MARK: - 准备工作
extension CameraView {
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
    
    /// 添加属性观察
    private func addObserver() {
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(self.handleSubjectAreaChange(noti:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput?.device)
        
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
                
                
                // setting flashModel
                self.flashModel = .auto
                // setting mediaQuality
                self.mediaQuality = .medium
                self.session.commitConfiguration()
                self.addObserver()
                self.session.startRunning()
                
            })
        }
        
        return true
    }
}

// MARK: - 其他
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
            self.videoDeviceInput = self.deviceInput(forDevicePosition: .back)
            
        case .front:
            self.videoDeviceInput = self.deviceInput(forDevicePosition: .front)
            
        }
        
        
        if self.videoDeviceInput != nil && self.session.canAddInput(self.videoDeviceInput!) {
            self.session.addInput(self.videoDeviceInput!)
            
//            if cameraPosion == .back {
//                videoConnection!.videoOrientation = (self.previewLayer.connection?.videoOrientation)!
//
//            }
            
            self.mediaQuality = .medium
            
        }
        
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
//    public func startCapturingVideo() -> Bool {
//
//        self.session.beginConfiguration()
//        if !self.hasCamera() {
//            return false
//
//        }
//
//        let connection = self.movieFileOutput?.connection(with: AVMediaType.video)
//        connection?.videoOrientation = (self.previewLayer.connection?.videoOrientation)!
//        self.session.commitConfiguration()
//
//        let tempFilePath = NSTemporaryDirectory() + "/" + "makeNoise\(arc4random()).mp4"
//        let tempVideoURL = URL.init(fileURLWithPath: tempFilePath)
    
//        PHPhotoLibrary.requestAuthorization { (status) in
//
//            if status == PHAuthorizationStatus.authorized {
//
//                try! PHPhotoLibrary.shared().performChangesAndWait {
//
//                    let videoRequest = PHAssetCreationRequest.init(for: PHAsset)
//
//                    videoRequest?.addResource(with: PHAssetResourceType.video, fileURL: tempVideoURL, options: nil)
//
//
//                }
//
//
//            }
//
//
//
//        }
        
//        self.movieFileOutput?.startRecording(to: tempVideoURL, recordingDelegate: self)
        
        

        
//        return true
//    }
//
//
//
//    public func stopCapturingVideo(withHandler handler: @escaping (_ videoUrl: URL?, _ error: Error?) -> ()) {
//        videoCompleteHandler = handler
//        movieFileOutput?.stopRecording()
//    }
    
    private func hasCamera() -> Bool {
        if self.deviceInput(forDevicePosition: .back) != nil
            ||
            self.deviceInput(forDevicePosition: .front) != nil {
            
            return true
            
        }else{
            
            return false
            
        }
    }
    
}


extension CameraView {

    func handleClassification(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation] else { fatalError() }
        let mlarray = observations[0].featureValue.multiArrayValue!
        let length = mlarray.count
        let doublePtr =  mlarray.dataPointer.bindMemory(to: Double.self, capacity: length)
        let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: length)
        let mm = Array(doubleBuffer)
        
        
        drawLine(mm)
        

    }
    
    func setPos(_ mm: Array<Double>) {
        let com = PoseEstimator(ImageWidth,ImageHeight)
        
        
        let humans = com.estimate(mm);
        
        var pos = [CGPoint]()
        for human in humans {
            for i in [4,7] {
                if human.bodyParts.keys.index(of: i) == nil {
                    continue
                }
                let bodyPart = human.bodyParts[i]!
                //centers[i] = CGPoint(x: bodyPart.x, y: bodyPart.y)
                let pt = CGPoint(x: Int(bodyPart.x * CGFloat(ImageWidth) + 0.5), y: Int(bodyPart.y * CGFloat(ImageHeight) + 0.5))
                pos.append(pt)
            }
            
        }
        print(pos)
        
        self.musicKeyboard.recognizedPointArray = pos
    
        
    }

    func drawLine(_ mm: Array<Double>) {
        let com = PoseEstimator(ImageWidth,ImageHeight)
        
      
        let humans = com.estimate(mm);
        
        var keypoint = [Int32]()
        var pos = [CGPoint]()
        var posSet = [CGPoint]()
        for human in humans {
            var centers = [Int: CGPoint]()
            for i in 0...CocoPart.Background.rawValue {
                if human.bodyParts.keys.index(of: i) == nil {
                    continue
                }
                let bodyPart = human.bodyParts[i]!
                //centers[i] = CGPoint(x: bodyPart.x, y: bodyPart.y)
                centers[i] = CGPoint(x: Int(bodyPart.x * CGFloat(ImageWidth) + 0.5), y: Int(bodyPart.y * CGFloat(ImageHeight) + 0.5))
                
                if i==4 || i==7{
                    self.musicKeyboard.recognizedPointArray.append(centers[i]!)
                }
            }
            
            for (pairOrder, (pair1,pair2)) in CocoPairsRender.enumerated() {
                
                if human.bodyParts.keys.index(of: pair1) == nil || human.bodyParts.keys.index(of: pair2) == nil {
                    continue
                }
                if centers.index(forKey: pair1) != nil && centers.index(forKey: pair2) != nil{
                    keypoint.append(Int32(pairOrder))
                    pos.append(centers[pair1]!)
                    pos.append(centers[pair2]!)
                    //                    addLine(fromPoint: centers[pair1]!, toPoint: centers[pair2]!, color: CocoColors[pairOrder])
                }
            }
        }
        print(posSet)
        
//        self.musicKeyboard.recognizedPointArray = pos
        
        let targetImageSize = CGSize(width: ImageWidth, height: ImageWidth)
        
        //UIGraphicsBeginImageContext(targetImageSize)
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(targetImageSize, false, scale)
        var context:CGContext = UIGraphicsGetCurrentContext()!
        
        for i in 0..<pos.count {
            if i%2 == 0 {
                let center1 = pos[i]
                let center2 = pos[i+1]
                
                let color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                addLine(context: &context, fromPoint: center1, toPoint: center2, color: color)
            }
        }
        
        var boneImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        if pos.count>0{
            boneImage = boneImage.resize(to: CGSize(width: ToolClass.getScreenWidth(), height: ToolClass.getScreenHeight()))
        }
        
        DispatchQueue.main.async {
            self.imageView.image = boneImage
        }
        
    }
    
    func addLine(context: inout CGContext, fromPoint start: CGPoint, toPoint end:CGPoint, color: UIColor) {
        context.setLineWidth(5.0)
        context.setStrokeColor(color.cgColor)
        
        context.move(to: start)
        context.addLine(to: end)
        
        context.closePath()
        context.strokePath()
    }
}

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), false, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}

extension CameraView {
    static func getVideoSetting() -> [String : AnyObject] {
        return [
            AVVideoCodecKey: AVVideoCodecType.h264 as AnyObject,
            AVVideoWidthKey: 320 as AnyObject,
            AVVideoHeightKey: 240 as AnyObject,
            AVVideoCompressionPropertiesKey: [
                AVVideoPixelAspectRatioKey: [
                    AVVideoPixelAspectRatioHorizontalSpacingKey: 1,
                    AVVideoPixelAspectRatioVerticalSpacingKey: 1
                ],
                AVVideoMaxKeyFrameIntervalKey: 1,
                AVVideoAverageBitRateKey: 1280000
                ] as AnyObject
        ]
        
        
        
    }
    
    static func getAudioSetting() -> [String : AnyObject]  {
        return [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 1 as AnyObject,
            AVSampleRateKey: 22050 as AnyObject
        ]
    }
    
    
}



