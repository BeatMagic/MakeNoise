//
//  TouchEventView.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/29.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit

private var touchEventViewContext = 0

class TouchEventView: UIView {
    /// 运动方向点
    var movementDirectionPoint: CGPoint = CGPoint.init(x: ToolClass.getScreenWidth() / 2, y: ToolClass.getScreenHeight() / 2) {
        didSet {
            // 当这个点不在自身里才开始运动
            DispatchQueue.main.async {
                if self.frame.contains(self.movementDirectionPoint) == false {
                    
                    // 得到需要运动的距离
                    let needTravelDistance = ToolClass.getDistance(point1: self.center, point2: self.movementDirectionPoint)
                    
                    self.bindingAnimation(duration: Double.init(needTravelDistance / TouchEventViewSettingModel.unitSpeed))
                    
                }
            }
        }
    }
    
    /// 点击下的跟随touch对象的地址
    var touchAddress: String = ""
    
    /// 外部代理
    weak var delegate: TouchEventViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.flatWhite
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        self.addObserver(self, forKeyPath: "center", options: [.new, .old ], context: &touchEventViewContext)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "center", context: &touchEventViewContext)
        
    }


}

extension TouchEventView {
    /// 重载属性观察
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &touchEventViewContext {
            guard let key = keyPath,
                let change = change,
                let newValue = change[.newKey] as? CGPoint,
                let oldValue = change[.oldKey] as? CGPoint else {

                    return
            }
            
            if key == "center" {
                self.delegate?.doWithDetermineTrack(oldPoint: oldValue, newPoint: newValue)
                
            }

        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            
        }
        
    }

}

extension TouchEventView {
    /// 获得一个设置好的直线动画
    func getPanAnimationArray(_ duration: CFTimeInterval) -> [CABasicAnimation] {
        let xPanAnimation = ToolClass.baseAnimationWithKeyPath(
            "transform.translation.x",
            fromValue: self.frame.origin.x,
            toValue: self.movementDirectionPoint.x,
            duration: duration,
            repeatCount: 0,
            timingFunction: CAMediaTimingFunctionName.easeOut.rawValue
        )
        
        let yPanAnimation = ToolClass.baseAnimationWithKeyPath(
            "transform.translation.y",
            fromValue: self.frame.origin.y,
            toValue: self.movementDirectionPoint.y,
            duration: duration,
            repeatCount: 0,
            timingFunction: CAMediaTimingFunctionName.easeOut.rawValue
        )
        
        return [xPanAnimation, yPanAnimation]
    }
    
    /// 绑定动画
    func bindingAnimation(duration: TimeInterval) -> Void {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [],
            animations: {
                self.center = self.movementDirectionPoint
            },
            completion: nil
        )

        
        
    }// funcEnd
    
}

protocol TouchEventViewDelegate: class {
    func doWithDetermineTrack(oldPoint: CGPoint, newPoint: CGPoint)
    
}
