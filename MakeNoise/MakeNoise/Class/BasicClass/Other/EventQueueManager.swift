//
//  EventQueue.swift
//  PlaygroundDemo
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class EventQueueManager: NSObject {
    
    static let MsgName = "BeatMessage"
    
    static var count:Int = 0
    static var lastCountTime : Double = 0.0
    //字典 key是groupid value是一个队列
    static var groupQueueDict = [Int:EventQueue]()
    
    static var currentEvent:[KeyTouchEvent]?
    
    static func AddEvent(groupId:Int, event:KeyTouchEvent){
        
        //先处理抬起的事件
        if event.type == KeyTouchEvent.TouchEventType.Exit{
            //收到抬起时看看有没有这个键的按下事件还在队列中，首先移除掉
//            if self.groupQueueDict.keys.contains(groupId){
//                let cque = self.groupQueueDict[groupId]
//                cque?.RemoveEvent(evtId: event.keyId)
//            }
            
        }else if event.type == KeyTouchEvent.TouchEventType.Enter{
            //确保某个beat只有一个事件
            event.inqueueId = self.count
            
            //没有这个队列
            if !self.groupQueueDict.keys.contains(groupId)
            {
                let nque = EventQueue()
                groupQueueDict.updateValue(nque, forKey: groupId)
            }
            let cque = self.groupQueueDict[groupId]
            cque?.AddEvent(event: event)
        }
    }
    
    static func postBeatMessage() -> Void {
        let name = NSNotification.Name(rawValue: EventQueueManager.MsgName)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    static func doEveryBeat(){
        self.count += 1
        self.lastCountTime = Date().timeIntervalSince1970
        
        currentEvent = []
        for (_, value) in self.groupQueueDict {
            if !value.IsEmpty(){
                currentEvent?.append(value.Pop())
            }
        }

        
        postBeatMessage()
    }
    
    static func getMsgById(){
        
    }
    
}
