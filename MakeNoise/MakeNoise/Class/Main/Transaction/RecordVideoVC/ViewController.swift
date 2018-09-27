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
    var cameraView: CameraView = {
        let tmpCameraView = CameraView.init(
            frame: CGRect.init(x: 0, y: 0, width: ToolClass.getScreenWidth(), height: ToolClass.getScreenHeight()),
            musicKeyboard: nil
        )
        
        
        return tmpCameraView
    }()

    var recordVideoButton: UIButton = {
        let tmpButton = UIButton.init(
            frame: CGRect.init(
                x: (ToolClass.getScreenWidth() - FrameStandard.recordVideoButtonSideLength) / 2,
                y: ToolClass.getScreenHeight() / 4 * 3,
                width: FrameStandard.recordVideoButtonSideLength,
                height: FrameStandard.recordVideoButtonSideLength
            )
        )
        
        tmpButton.layer.cornerRadius = FrameStandard.recordVideoButtonSideLength / 2
        tmpButton.layer.masksToBounds = true
        tmpButton.backgroundColor = UIColor.flatRed
        
        tmpButton.titleLabel?.text = "燥!"
        tmpButton.titleLabel?.textColor = UIColor.flatWhite
        
        return tmpButton
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.cameraView)
        
        self.recordVideoButton.addTarget(self, action: #selector(self.takePicture(sender:)), for: .touchUpInside)
        
        self.view.addSubview(self.recordVideoButton)
        
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
    @objc func takePicture(sender: UIButton) {
        // 录视频
        if sender.isSelected {// 正在录制, 点击停止
            self.cameraView.stopCapturingVideo(withHandler: { (videoUrl, error) in
                print(videoUrl as Any)
            })
            sender.isSelected = false
            
        } else {// 点击开始录制
            sender.isSelected = true
            
            let _ = self.cameraView.startCapturingVideo()
            
        }
        
        
    }
}

