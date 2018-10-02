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
            let sectionTime = StandardBeatsCountInOneSection * (60 / BeatsCountInOneMinute)
            let everyBeatTime = 60 / BeatsCountInOneMinute

            self.LocalEveryBeatTime = everyBeatTime
            BeatTimer.setBeatTimer(everyBeatTime: everyBeatTime, sectionTime: sectionTime)
        }
    }
    
    /// 标准: 一小节几个Beat
    static var StandardBeatsCountInOneSection: Double = 16 {
        didSet {
            let sectionTime = StandardBeatsCountInOneSection * (60 / BeatsCountInOneMinute)
            let everyBeatTime = 60 / BeatsCountInOneMinute
            
            self.LocalEveryBeatTime = everyBeatTime
            BeatTimer.setBeatTimer(everyBeatTime: everyBeatTime, sectionTime: sectionTime)
        }
    }
    
    /// 本地设置: 一小节几个Beat
//    static var LocalBeatsCountInOneSection: Double = 16 {
//        didSet {
//            let sectionTime = BeatsCountInOneMinute / 60 * 4
//            let everyBeatTime = sectionTime / 16
//
//            self.LocalEveryBeatTime = everyBeatTime
//            BeatTimer.setBeatTimer(everyBeatTime: everyBeatTime, sectionTime: sectionTime)
//        }
//    }
    
    /// 每个Beat多长时间
    static var LocalEveryBeatTime: Double = 4 / 16

    
    /// 音色文件名数组 [[音色文件名]] (按照按钮排列)
    static let toneFileWithKeyArray: [[[String]]] = [
        [
            ["0_01_D1.wav"],
            [],
        ],
        [
            ["1_01_E1.wav"],
            [],
        ],
        [
            ["2_01_F1.wav"],
            [],
        ],
        [
            ["3_01_G1.wav"],
            [],
        ],
        [
            ["4_01_B1.wav", "4_02_C2.wav", "4_03_G2.wav"],
            [],
        ],
        
        [
            ["5_01_C2.wav", "5_02_B1.wav"],
            [],
        ],
        [
            ["6_01_C1.wav", "6_02_B2.wav"],
            [],
        ],
        [
            ["7_01_D2.wav", "7_02_G2.wav", "7_03_E2.wav" ],
            [],
        ],
        [
            ["8_01_E2.wav", "8_02_G2.wav"],
            [],
        ],
        [
            ["9_01_F2.wav", "9_02_A2.wav", "9_03_G2.wav"],
            [],
        ],
        [
            ["10_01_G2.wav", "10_02_A2.wav", "10_03_F2.wav"],
            [],
        ],
        [
            ["11_01_A1.wav"],
            [],
        ]
    ]

}
