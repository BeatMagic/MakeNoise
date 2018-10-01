//
//  MusicAttributesModel.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/15.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class MusicAttributesModel: NSObject {
    
    /// 一分钟的拍子数
    static var BeatsCountInOneMinute: Double = 60 {
        didSet {
            let sectionTime = 4/(BeatsCountInOneMinute / 60)
            let everyBeatTime = sectionTime / 16

            self.LocalEveryBeatTime = everyBeatTime
            BeatTimer.setBeatTimer(everyBeatTime: everyBeatTime, sectionTime: sectionTime)
        }
    }
    
    /// 标准: 一小节几个Beat
    static var StandardBeatsCountInOneSection: Double = 4 {
        didSet {
            let sectionTime = BeatsCountInOneMinute / 60 * 4
            let everyBeatTime = sectionTime / 16
            
            self.LocalEveryBeatTime = everyBeatTime
            BeatTimer.setBeatTimer(everyBeatTime: everyBeatTime, sectionTime: sectionTime)
        }
    }
    
    /// 本地设置: 一小节几个Beat
    static var LocalBeatsCountInOneSection: Double = 16 {
        didSet {
            let sectionTime = BeatsCountInOneMinute / 60 * 4
            let everyBeatTime = sectionTime / 16
            
            self.LocalEveryBeatTime = everyBeatTime
            BeatTimer.setBeatTimer(everyBeatTime: everyBeatTime, sectionTime: sectionTime)
        }
    }
    
    /// 每个Beat多长时间
    static var LocalEveryBeatTime: Double = 4 / 16

    
    /// 音色文件名数组 [[音色文件名]] (按照按钮排列)
    static let toneFileWithKeyArray: [[[String]]] = [
        [
            ["0st_01_C1.wav", "0st_02_B2.wav"],
            [],
        ],
        [
            ["1st_01_A1.wav"],
            [],
        ],
        [
            ["2st_01_D1.wav"],
            [],
        ],
        [
            ["3st_01_E1.wav"],
            [],
        ],
        [
            ["4st_01_F1.wav"],
            [],
        ],
        
        [
            ["5st_01_G1.wav"],
            [],
        ],
        [
            ["6st_01_B1.wav", "6st_02_C2.wav", "6st_02_G2.wav"],
            [],
        ],
        [
            ["7st_01_C2.wav", "7st_02_B1.wav" ],
            [],
        ],
        [
            ["8st_01_D2.wav", "8st_02_G2.wav", "8st_03_E2.wav"],
            [],
        ],
        [
            ["9st_01_E2.wav", "9st_02_G2.wav"],
            [],
        ],
        [
            ["10st_01_F2.wav", "10st_02_A2.wav", "10st_03_G2.wav"],
            [],
        ],
    ]

}
