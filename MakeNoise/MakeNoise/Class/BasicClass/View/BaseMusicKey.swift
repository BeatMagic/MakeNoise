//
//  BaseMusicKey.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/15.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

private var clickCounterContext = 0

class BaseMusicKey: UIView {
    /// 主键
    let mainKey: Int!
    
    /// 边框颜色
    var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
    
    /// 按键种类
    let kind: MusicKeyAttributesModel.KeyKinds!

    /// 音色模型数组
    let tomeModelArray: [ToneItemModel]!
    
    /// 高播放优先级的音色模型数组
    var highPriorityTomeModelArray: [ToneItemModel] = []
    
    /// 点按次数
    var pressedCount: Int = 0
    
    /// 上次点按时间
    var lastPressedTime: Double = 0
    
    /// 上次点按音符数字
    var lastPressedNote: UInt8 = 0
    
    /// 按钮状态
    var pressStatus: MusicKeyAttributesModel.KeyStatus = .Unpressed {
        didSet {
            var eventType = KeyTouchEvent.TouchEventType.Exit
            if pressStatus == .Pressed {
                eventType = KeyTouchEvent.TouchEventType.Enter
                
                
            }
//            else if pressStatus == .Unpressed && self.kind == MusicKeyAttributesModel.KeyKinds.Movable {
//
//                //抬起事件除了要添加事件处理，还要自己在内部处理停止发声逻辑
//                self.stopNoise()
//            }
            
            let ktevent = KeyTouchEvent(id:mainKey,ctime:Date().timeIntervalSince1970,type:eventType)
            EventQueueManager.AddEvent(groupId: mainKey, event: ktevent)
          
            
        }
    }

    
    
    init(frame: CGRect,
         mainKey: Int,
         borderColor: UIColor,
         tomeModelArray: [ToneItemModel],
         kind: MusicKeyAttributesModel.KeyKinds) {
        
        self.mainKey = mainKey
        self.borderColor = borderColor
        self.kind = kind
        self.tomeModelArray = tomeModelArray
        
        super.init(frame: frame)
        
        self.setData()
        self.setUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - 设置自身属性
extension BaseMusicKey {
    /// 设置UI
    func setUI() -> Void {
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = FrameStandard.KeyBorderWidthAggregate.normal.rawValue
        self.layer.cornerRadius = FrameStandard.KeyBorderWidthAggregate.normal.rawValue * 4
        
    }// funcEnd
    
    /// 设置数据
     @objc func setData() -> Void {
        let name = Notification.Name(rawValue: EventQueueManager.MsgName)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.makeNoise),
                                               name: name,
                                               object: nil)


    }// funcEnd
    
    /// [通知调用]发出声音
    @objc func makeNoise() -> Void {
        
        if EventQueueManager.currentEvent != nil {
            for evt in EventQueueManager.currentEvent!{
                if evt.keyId == self.mainKey{
                    
                    var playToneModel: ToneItemModel
                    let nowTimeInterval = Date().timeIntervalSince1970
                    
                    
                    if self.highPriorityTomeModelArray.count == 0 {
                        
                        // 两次点击之间小于等于单位长度
                        if (nowTimeInterval - self.lastPressedTime) / 1000 <= MusicAttributesModel.LocalEveryBeatTime {
                            let tmpCount = Int.random(in: 0 ..< self.tomeModelArray.count)
                            playToneModel = self.tomeModelArray[tmpCount]
                            
                            
                        }else {
                            playToneModel = self.tomeModelArray[self.pressedCount % self.tomeModelArray.count]
                            self.pressedCount += 1
                        }
                        
                    }else {
                        playToneModel = self.highPriorityTomeModelArray.first!
                        self.highPriorityTomeModelArray.remove(at: 0)
                        
                    }
                
                    self.lastPressedNote = playToneModel.pitch
                    self.lastPressedTime = nowTimeInterval
                    
                    let mySampler = TimbreManager.getSampler(keyIndex: self.mainKey)
                    try! mySampler.play(noteNumber: playToneModel.pitch, velocity: 95, channel: 1)
                    
                    
                    
                    DispatchQueue.main.async {
                        
                        let color = self.backgroundColor
                        self.backgroundColor = UIColor.init(red: 232, green: 236, blue: 238, alpha: 0.001)
                        
                        self.shake()
                        
                        DelayTask.createTaskWith(workItem: {
                             self.backgroundColor = color
                        }, delayTime: 0.1)
                    }
                    
                }
            }

        }
    }
    
    func stopNoise() -> Void {
        let mySampler = TimbreManager.getSampler(keyIndex: self.mainKey)
        try! mySampler.stop(noteNumber: self.lastPressedNote, channel: 1)

    }
}
