//
//  TouchEventViewSettingModel.swift
//  MakeNoise
//
//  Created by X Young. on 2018/9/30.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class TouchEventViewSettingModel: NSObject {
    /// 小球单位速度 (0.1秒走100CGFloat)
    static let unitSpeed: CGFloat = 100 / 0.05
    
    /// 记录距离的模型数组
//    static var TouchEventDistanceModelArray: [TouchEventRecordDistance] = []
}

class TouchEventRecordDistance: NSObject {
    /// 目标Touch对象
    let targetTouch: UITouch?
    
    /// 目标运动点
    let targetPoint: CGPoint?
    
    /// 触摸点到第一个球的距离
    let distanceToFirstBall: CGFloat!
    
    /// 触摸点到第一个球的距离
    let distanceToSecondBall: CGFloat!
    
    init(targetTouch: UITouch?, targetPoint: CGPoint?, distanceToFirstBall: CGFloat, distanceToSecondBall: CGFloat) {
        
        self.targetTouch = targetTouch
        self.targetPoint = targetPoint
        
        self.distanceToFirstBall = distanceToFirstBall
        self.distanceToSecondBall = distanceToSecondBall
        
        super.init()
    }
}
