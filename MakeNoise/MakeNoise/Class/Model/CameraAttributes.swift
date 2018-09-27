//
//  CameraAttributes.swift
//  MakeNoise
//
//  Created by X Young. on 2018/9/27.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraAttributes: NSObject {
    
    /// 是哪个摄像头
    enum CameraPosition: Int {
        /// 后置
        case back
        
        /// 前置
        case front
    }
    
    /// 闪光灯模式
    public enum FlashMode: Int {
        case on, off, auto
        
    }
    
    /// 媒体质量
    enum MediaQuality: Int {
        case high, medium, low
    }
}
