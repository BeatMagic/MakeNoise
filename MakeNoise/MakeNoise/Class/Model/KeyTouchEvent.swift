//
//  KeyTouchEvent.swift
//  PlaygroundDemo
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class KeyTouchEvent: NSObject {
    /// 按钮音色枚举
    enum TouchEventType: Int {
        case Enter = 0, Exit
        
    }
    
    var timeStamp:Double!
    var type:TouchEventType!
    var keyId:Int!
    
    //进queue时候一个id
    var inqueueId:Int?
    
    init(id:Int, ctime:Double,type:TouchEventType){
        self.keyId = id
        self.timeStamp = ctime
        self.type = type
        super.init()
    }
}
