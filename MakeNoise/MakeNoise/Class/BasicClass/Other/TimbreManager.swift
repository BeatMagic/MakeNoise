//
//  TimbreManager.swift
//  PlaygroundDemo
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AudioKit

class TimbreManager: NSObject {
    
    static var soundEngine = SoundEngine()
    
    override init(){
        super.init()
        
        self.initAllTimbre()
    }
    
    static func getSampler(keyIndex: Int) ->AKMIDISampler{
        
        return self.soundEngine.GetSampler(keyIndex: keyIndex)
    }
    
    /// 初始化所有音色
    private func initAllTimbre() -> Void {
        for index in 0 ..< MusicAttributesModel.toneFileWithKeyArray.count {
            let normalFileNameArray = MusicAttributesModel.toneFileWithKeyArray[index].first!
            let highFileNameArray = MusicAttributesModel.toneFileWithKeyArray[index].last!
            
            let normalAudioFileArray = self.getAKAudioFileArrayFrom(normalFileNameArray)
            let highAudioFileArray = self.getAKAudioFileArrayFrom(highFileNameArray)
            
            let sampler: AKMIDISampler = {
                let tmpSampler = AKMIDISampler()
                try! tmpSampler.loadAudioFiles(normalAudioFileArray + highAudioFileArray)
                
                return tmpSampler
            }()
            
            TimbreManager.soundEngine.RegistTimbre(keyIndex: index, sampler: sampler)
        }
        
        
    }// funcEnd
    
}

extension TimbreManager {
    /// 通过一个文件名数组 返回一个AKAudioFile数组
    func getAKAudioFileArrayFrom(_ fileNameArray: [String]) -> [AKAudioFile] {
        var audioFileArray: [AKAudioFile] = []
        
        for fileName in fileNameArray {
            audioFileArray.append(try! AKAudioFile(readFileName: fileName))
        }
        
        return audioFileArray
        
    }// funcEnd
}

