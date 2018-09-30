//
//  ViewController.swift
//  MakeNoise
//
//  Created by X Young. on 2018/9/27.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import ChameleonFramework

class ViewController: UIViewController {

// MARK: - UI成员
    var cameraView: CameraView = {
        let tmpCameraView = CameraView.init(
            frame: CGRect.init(x: 0, y: 0, width: ToolClass.getScreenWidth(), height: ToolClass.getScreenHeight()),
            musicKeyboard: OperateKeysView.init(frame: CGRect.init(
                x: 0,
                y: 0,
                width: ToolClass.getScreenWidth(),
                height: ToolClass.getScreenHeight()))
        )
        
        
        return tmpCameraView
    }()

    /// 拍摄按钮
    let recordVideoButton: UIButton = {
        let tmpButton = UIButton.init(
            frame: CGRect.init(
                x: (ToolClass.getScreenWidth() - FrameStandard.recordVideoButtonSideLength) / 2,
                y: ToolClass.getScreenHeight() / 6 * 5,
                width: FrameStandard.recordVideoButtonSideLength,
                height: FrameStandard.recordVideoButtonSideLength
            )
        )
        
        tmpButton.layer.cornerRadius = FrameStandard.recordVideoButtonSideLength / 2
        tmpButton.layer.masksToBounds = true
        tmpButton.backgroundColor = UIColor.flatRed
        
        tmpButton.setTitle("燥!", for: .normal)
        tmpButton.setTitleColor(UIColor.flatWhite, for: .normal)
        
        tmpButton.setTitle("停止", for: .selected)
        tmpButton.setTitleColor(UIColor.flatWhite, for: .selected)
        
        return tmpButton
    }()
    
    /// 切换摄像头
    let switchCameraButton: UIButton = {
        let width: CGFloat = 90
        let height: CGFloat = 30
        
        let tmpButton = UIButton.init(
            frame: CGRect.init(
                x: ToolClass.getScreenWidth() - width - 10,
                y: ToolClass.getScreenHeight() - height - height,
                width: width,
                height: height
            )
        )
        
        tmpButton.backgroundColor = UIColor.flatBlack
        tmpButton.alpha = 0.15
        tmpButton.setTitle("切换摄像头", for: .normal)
        tmpButton.setTitleColor(UIColor.flatWhite, for: .normal)
        tmpButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        return tmpButton
    }()

// MARK: - Data成员
    var timbreMgr: TimbreManager!

// MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setData()
        self.setUI()
        
        
        let isSuccess = self.cameraView.prepareCamera()
        
        if !isSuccess {
            print("没有相机")
        }
        
        self.cameraView.setHandlerWhenCannotAccessTheCamera {
            print("用户未授权访问相机")
        }
    }

}

extension ViewController {
    func setData() -> Void {
        self.recordVideoButton.addTarget(self, action: #selector(self.takePicture(sender:)), for: .touchUpInside)
        self.switchCameraButton.addTarget(self, action: #selector(self.switchCamera), for: .touchUpInside)
        
        self.timbreMgr = TimbreManager()
        BeatTimer.delegate = self
        MusicAttributesModel.BeatsCountInOneMinute = 90
    }
    
    
    func setUI() -> Void {
        self.cameraView.musicKeyboard.backgroundColor = UIColor.clear
        self.view.addSubview(self.cameraView)

        self.view.addSubview(self.recordVideoButton)
        self.view.addSubview(self.switchCameraButton)
    }
    
    /// 录制视频点击事件
    @objc func takePicture(sender: UIButton) -> Void {
        if sender.isSelected { // 正在录制, 点击停止
            
            let playVideoViewController = UIViewController.initVControllerFromStoryboard("PlayVideoViewController") as! PlayVideoViewController
            playVideoViewController.modalTransitionStyle = .flipHorizontal
            
            self.cameraView.stopCapturingVideo(withHandler: { (videoUrl, error) in
                playVideoViewController.videoFileUrl = videoUrl
                
            })
            
            sender.isSelected = false
            self.switchCameraButton.isHidden = false
            
            self.present(playVideoViewController, animated: true, completion: nil)
            
            
        } else {// 点击开始录制
            sender.isSelected = true
            
            let _ = self.cameraView.startCapturingVideo()
            
            self.switchCameraButton.isHidden = true
        }
        
    }
    
    
    /// 切换摄像头点击事件
    @objc func switchCamera() -> Void {
        self.cameraView.autoChangeCameraPosition()
        
    }
    
}

extension ViewController: BeatTimerDelegate {
    func doThingsWhenTiming() {
        EventQueueManager.doEveryBeat()
        
    }
    
}


