//
//  EventQueue.swift
//  PlaygroundDemo
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class EventQueue: NSObject {
    var eventSeq = [KeyTouchEvent]()
    
    //队末的id
    var lastInqueueId:Int?
    
    func AddEvent(event:KeyTouchEvent)
    {
        //保留最后一个其余丢弃
        if event.inqueueId == lastInqueueId && !self.IsEmpty(){
             eventSeq.removeLast()
        }
        eventSeq.append(event)
        self.lastInqueueId = event.inqueueId
        
    }
    
    func RemoveEvent(evtId:Int){
        var temp = [KeyTouchEvent]()
        for kte in self.eventSeq{
            if kte.keyId != evtId {
                temp.append(kte)
            }else {
                if kte.inqueueId == lastInqueueId{
                    lastInqueueId = nil
                }
            }
        }
        eventSeq = temp
    }
    
    func IsEmpty()->Bool{
        
        return eventSeq.count==0
    }
    
    func Pop()->KeyTouchEvent{
        let rt = eventSeq.first
        eventSeq.removeFirst()
        return rt!
    }
}
