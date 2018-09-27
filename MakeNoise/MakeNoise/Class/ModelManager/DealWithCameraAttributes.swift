//
//  deal with deal with DealWithCameraAttributes.swift
//  MakeNoise
//
//  Created by X Young. on 2018/9/27.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class DealWithCameraAttributes: NSObject {
    
    /// 闪光灯模式转换
    static func changeToAvFlashModel(_ mode: CameraAttributes.FlashMode) -> AVCaptureDevice.FlashMode {
        switch mode {
        case .auto:
            return .auto
            
        case .on:
            return .on
            
        case .off:
            return .off
        }
    }
    
    /// 媒体质量转换
    static func changeToAvPreset(_ mode: CameraAttributes.MediaQuality) -> String {
        switch mode {
        case .high:
            return AVCaptureSession.Preset.high.rawValue
            
        case .medium:
            return AVCaptureSession.Preset.medium.rawValue
            
        case .low:
            return AVCaptureSession.Preset.low.rawValue
            
        }
    }
}
