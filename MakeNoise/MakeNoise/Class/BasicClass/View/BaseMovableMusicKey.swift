//
//  BaseMovableMusicKey.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/17.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

class BaseMovableMusicKey: BaseMusicKey {
    
    let initialFrame: CGRect!
    
    override init(frame: CGRect, mainKey: Int, borderColor: UIColor, tomeModelArray: [ToneItemModel], kind: MusicKeyAttributesModel.KeyKinds) {
        self.initialFrame = frame
        
        super.init(frame: frame,
                   mainKey: mainKey,
                   borderColor: borderColor,
                   tomeModelArray: tomeModelArray,
                   kind: .Movable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setData() {
        super.setData()
    
    }
    
}
