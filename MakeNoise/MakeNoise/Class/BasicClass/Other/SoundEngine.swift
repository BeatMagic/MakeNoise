//
//  SoundEngine.swift
//  PlaygroundDemo
//
//  Created by apple on 2018/9/15.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AudioKit

class SoundEngine: NSObject {
    
    var mixer  = AKMixer()
    
    //这里key是音色的枚举， 对应一个midiSampler
    var timbreDict = [Int: AKMIDISampler]()
    
    //这里设置总的混响，延音等
    
    override init(){
        
        AudioKit.output = mixer
        do {
            try AudioKit.start()
            
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        super.init()
    }
    
    func GetSampler(keyIndex: Int) -> AKMIDISampler{
  
        let returnValue = self.timbreDict[keyIndex]
        return returnValue!
    }
    
    func RegistTimbre(keyIndex:Int, sampler: AKMIDISampler){
        self.timbreDict.updateValue(sampler, forKey: keyIndex)
        mixer.connect(input: sampler)
    }
    
    
    
}
