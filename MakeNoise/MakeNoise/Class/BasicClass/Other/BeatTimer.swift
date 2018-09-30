//
//  BeatTimer.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/17.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class BeatTimer: NSObject {
    
    /// 每个Beat多少秒(即循环时间)
    static private var everyBeatTime: Double = 1 / 16
    
    /// 每个Section多少秒
    static private var sectionTime: Double = 4
    
    /// 当前BeatTime
    static private var currentBeatTime: Double = 0
    
    /// 计时器
    static private var shared: DispatchSourceTimer? = nil
    
    /// 外部代理
    weak static var delegate: BeatTimerDelegate?
    
}

extension BeatTimer {
    /// 初始化
    static private func initBeatTimer() -> Void {
        if self.shared != nil {
            self.shared!.cancel()
            self.shared = nil
            
        }
        
        self.currentBeatTime = 0
        
        let timer: DispatchSourceTimer? = DispatchSource.makeTimerSource()
        timer!.schedule(deadline: DispatchTime.now(),
                        repeating: self.everyBeatTime,
                        leeway: DispatchTimeInterval.seconds(0))
        timer!.setEventHandler(handler: {
            self.delegate?.doThingsWhenTiming()
            self.currentBeatTime += self.everyBeatTime
            
            if self.currentBeatTime == sectionTime {
                self.currentBeatTime = 0
            }
        })
        
        self.shared = timer
        self.shared!.resume()

    }
    
    /// 获取当前BeatTime
    static func getCurrentBeatTime() -> Double {
        return self.currentBeatTime
    }
    
    /// 设置BeatTimer的循环时间与小节时间
    static func setBeatTimer(everyBeatTime: Double, sectionTime: Double) -> Void {
        self.everyBeatTime = everyBeatTime
        self.sectionTime = sectionTime
        
        self.initBeatTimer()
    }
    
}

protocol BeatTimerDelegate: class {
    func doThingsWhenTiming()
}
