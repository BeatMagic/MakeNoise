//
//  OperateKeysView.swift
//  PlaygroundDemo
//
//  Created by X Young. on 2018/9/15.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import ChameleonFramework

class OperateKeysView: UIView {
    /// 按钮数组
    private var musicKeyArray: [BaseMusicKey] = []
    
    /// 按钮frame数组
    private var musicKeyViewModelArray: [MusicKeyViewModel] = []
    
    /// 运动轨迹模型
    private var touchEventDistanceModelArray: [TouchEventRecordDistance] = []
    
    
    /// 正在进行的touch对象数组
    private var presentTouchArray: [UITouch] = []
    
    
    /// 模拟Touch点的UIView数组
    private let touchEventViewArray: [TouchEventView] = {
        var tmpArray: [TouchEventView] = []
        for index in 0 ..< 17 {
            let touchEventView = TouchEventView.init(
                frame: CGRect.init(
                    x: ToolClass.getScreenWidth() / 2 - 15, y: ToolClass.getScreenHeight() / 2 - 15,
                    width: 30, height: 30)
            )
            touchEventView.isHidden = true
            
            tmpArray.append(touchEventView)
            
        }
        
        return tmpArray
    }()
    
    /// 上次识别出来的点数组
    private var prevRecognizedPointArray: [CGPoint?] = [nil, nil]
    
    /// 可以穿参数标识
    var Signage: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setData()
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - 自身属性的设置等
extension OperateKeysView {
    /// setData
    func setData() -> Void {
        let tmpRect = CGRect.init(x: 40, y: 40, width: 40, height: 40)
        self.musicKeyViewModelArray = [
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .Movable),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .Normal),
        ]
        
        let generalWidth: CGFloat = 250
        let generalX: CGFloat  = (ToolClass.getScreenWidth() - generalWidth) / 3 * 2
        let generalHeight: CGFloat  = 30
        let initialY: CGFloat  = 250
        let marginTop: CGFloat = 10
        
        
        for index in 0 ..< self.musicKeyViewModelArray.count {
            let viewModel = self.musicKeyViewModelArray[index]
            
            switch index {
                
            // 唯一一个大的普通
            case 0:
                viewModel.ownFrame = CGRect.init(x: generalX / 2 ,
                                                 y: generalX + 25,
                                                 width: ToolClass.getScreenWidth() - generalX,
                                                 height: 1 * generalX)
                
            // 唯一一个可拖动
            case 1:
                viewModel.ownFrame = CGRect.init(x: (ToolClass.getScreenWidth() - 50) / 2,
                                                 y: generalX,
                                                 width: 50,
                                                 height: 50)
                
            // 两个边框可变
            case 2, 3:
                viewModel.ownFrame = CGRect.init(
                    x: (ToolClass.getScreenWidth() - 100 * 2 - generalHeight) / 2,
                    y: generalX + 70,
                    width: 100,
                    height: 50
                )
                
                if index == 3 {
                    viewModel.ownFrame = CGRect.init(
                        x: (ToolClass.getScreenWidth() - 100 * 2 - generalHeight) / 2 + 100 + generalHeight,
                        y: generalX + 70,
                        width: 100,
                        height: 50
                    )
                }
                
            // 右下角大的
            case 8:
                viewModel.ownFrame = CGRect.init(
                    x: ToolClass.getScreenWidth() / 2 + generalHeight / 2,
                    y: ToolClass.getScreenHeight() - 250,
                    width: ToolClass.getScreenWidth() / 2 - generalHeight,
                    height: 70
                )
                
            case 9:
                
                viewModel.ownFrame = CGRect.init(
                    x: ToolClass.getScreenWidth() / 2 + generalHeight / 2 + marginTop * 1.5,
                    y: ToolClass.getScreenHeight() - 250 + marginTop * 1.5,
                    width: ToolClass.getScreenWidth() / 2 - generalHeight - marginTop * 3,
                    height: 70 - marginTop * 3
                )
                
            // 左下角
            case 10:
                viewModel.ownFrame = CGRect.init(
                    x: generalHeight / 2,
                    y: ToolClass.getScreenHeight() - 250,
                    width: ToolClass.getScreenWidth() / 2 - generalHeight,
                    height: 70
                )
                
            default:
                viewModel.ownFrame = CGRect.init(x: generalX,
                                                 y: initialY + CGFloat((index - 4)) * (marginTop + generalHeight),
                                                 width: generalWidth,
                                                 height: generalHeight)
                
            }
            
        }
        
    }
    
    /// setUI
    func setUI() -> Void {
        self.backgroundColor = UIColor.black
        self.isMultipleTouchEnabled = true
        self.isUserInteractionEnabled = true
        
        
        var viewModelIndex = 0
        
        for viewModel in self.musicKeyViewModelArray {
            
            var musicKey: BaseMusicKey
            let normalFileArray = MusicAttributesModel.toneFileWithKeyArray[viewModelIndex].first!
            var tomeModelArray: [ToneItemModel] = []
            
            
            
            for fileName in normalFileArray {
                let model = ToneItemModel.init(toneFileName: fileName)
                tomeModelArray.append(model)
            }
            
            if viewModel.ownKind == .Movable {
                
                musicKey = BaseMovableMusicKey.init(
                    frame: viewModel.ownFrame,
                    mainKey: viewModelIndex,
                    borderColor: .white,
                    tomeModelArray: tomeModelArray,
                    kind: viewModel.ownKind
                )
                
            }else {
                
                musicKey = BaseMusicKey.init(
                    frame: viewModel.ownFrame,
                    mainKey: viewModelIndex,
                    borderColor: .white,
                    tomeModelArray: tomeModelArray,
                    kind: viewModel.ownKind
                )
                
            }
            
            switch viewModel.ownKind {
            case .Movable?:
                musicKey.borderColor = UIColor.clear
                musicKey.backgroundColor = UIColor.flatOrange
                
                //                let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.draggedView(_:)))
                //                panGesture.cancelsTouchesInView = false
                //                panGesture.delaysTouchesBegan = false
                //                panGesture.delaysTouchesEnded = false
                //                musicKey.addGestureRecognizer(panGesture)
                
                
            case .BorderVariable?:
                musicKey.borderColor = UIColor.flatOrange
                
            default:
                print("普通类型")
            }
            
            self.addSubview(musicKey)
            self.musicKeyArray.append(musicKey)
            
            
            
            viewModelIndex += 1
        }
        
        for musicKey in self.musicKeyArray {
            if musicKey.kind == .Movable {
                self.bringSubviewToFront(musicKey)
            }
        }
        
        for touchEventView in self.touchEventViewArray {
            self.addSubview(touchEventView)
            self.bringSubviewToFront(touchEventView)
            touchEventView.delegate = self
        }
        
    }
    
}

// MARK: - 拖动等动作事件
extension OperateKeysView {
    //    @objc func draggedView(_ sender: UIPanGestureRecognizer){
    //        let keyDrag = self.musicKeyArray[1] as! BaseMovableMusicKey
    //        self.bringSubview(toFront: keyDrag)
    //
    //        switch sender.state {
    //        case .began:
    //            keyDrag.ownCenter = keyDrag.center
    //
    //        case .ended, .failed, .cancelled:
    //            keyDrag.center = keyDrag.ownCenter
    //
    //        default:
    //            let location = sender.location(in: self)
    //            keyDrag.center = location
    //        }
    //
    //    }
    
    
}

// MARK: - 重载Touch事件
extension OperateKeysView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            if self.presentTouchArray.contains(touch) == false {
                self.presentTouchArray.append(touch)
                
            }
            
        }
        
        
        
//        if self.presentTouchArray.count == 1 {
//            self.touchStatus = 1
//
//        }else {
//            self.touchStatus = 2
//
//        }
        
        
        switch self.presentTouchArray.count {
        case 1:
            let touch = presentTouchArray.first!
            let touchAddress = String(format: "%p",  touch)
            
            if self.touchEventViewArray[1].isHidden == true { // 屏幕上只有一个点直接吸附
                let touchEventView = self.touchEventViewArray[0]
                touchEventView.touchAddress = touchAddress
                touchEventView.movementDirectionPoint = touch.location(in: self)
                
            }else { // 屏幕上有两个点 选择其中最近的吸附
                var distanceArray: [CGFloat] = []
                
                for touchEventView in self.touchEventViewArray {
                    let touchEventViewToTouch = ToolClass.getDistance(point1: touch.location(in: self), point2: touchEventView.center)
                    
                    distanceArray.append(touchEventViewToTouch)
                }
                
                if distanceArray[0] < distanceArray[1] {
                    self.touchEventViewArray[0].touchAddress = touchAddress
                    self.touchEventViewArray[0].movementDirectionPoint = touch.location(in: self)
                    
                }else {
                    self.touchEventViewArray[1].touchAddress = touchAddress
                    self.touchEventViewArray[1].movementDirectionPoint = touch.location(in: self)
                    
                }
                
            }
            
            
            
            
            
        default:
            for touch in self.presentTouchArray {
                
                let distanceToFirst = ToolClass.getDistance(
                    point1: self.touchEventViewArray[0].center,
                    point2: touch.location(in: self)
                )
                
                let distanceToSecond = ToolClass.getDistance(
                    point1: self.touchEventViewArray[1].center,
                    point2: touch.location(in: self)
                )
                
                let touchEventDistanceModel = TouchEventRecordDistance.init(
                    targetTouch: touch, targetPoint: nil,
                    distanceToFirstBall: distanceToFirst,
                    distanceToSecondBall: distanceToSecond
                )
                
                self.touchEventDistanceModelArray.append(touchEventDistanceModel)
            }
            
            self.touchEventDistanceModelArray.sort { (modelA, modelB) -> Bool in
                return modelA.distanceToFirstBall < modelB.distanceToFirstBall
            }
            
            let nearestTouchModelToFirst = self.touchEventDistanceModelArray.first!
            self.touchEventViewArray[0].touchAddress = String(format: "%p",  nearestTouchModelToFirst.targetTouch!)
            self.touchEventViewArray[0].movementDirectionPoint = nearestTouchModelToFirst.targetTouch!.location(in: self)
            
            
            if self.touchEventViewArray[1].isHidden == false {
                self.touchEventDistanceModelArray.sort { (modelA, modelB) -> Bool in
                    return modelA.distanceToSecondBall < modelB.distanceToSecondBall
                }
                
                let nearestTouchModelToSecond = self.touchEventDistanceModelArray.first!
                self.touchEventViewArray[1].touchAddress = String(format: "%p",  nearestTouchModelToSecond.targetTouch!)
                self.touchEventViewArray[1].movementDirectionPoint = nearestTouchModelToSecond.targetTouch!.location(in: self)
            }
            
            self.touchEventDistanceModelArray.removeAll()
            
            
        }
        
        
        
        
        
    }
    
    
    //        switch self.presentTouchArray.count {
    //        case 1:
    
    //
    //        default:
    //
    //
    //        }
    //    }
    
    //                if touchEventView.isHidden == false {
    //
    //                    let touchEventViewToTouch = ToolClass.getDistance(point1: touch.location(in: self), point2: touchEventView.frame.origin)
    //
    //                    if rootDistance > touchEventViewToTouch {
    //                        rootDistance = touchEventViewToTouch
    //
    //                        touchEventView.touchAddress = touchAddress
    //                        touchEventView.movementDirectionPoint = touch.location(in: self)
    //                    }
    //                }
    
    //            let pressedKey = self.judgeTouchMusicKey(touch.location(in: self))
    //
    //            let isSameTouchAddress = self.judgeTouchAddress(address: touchAddress, key: pressedKey)
    //
    //            if isSameTouchAddress != true {
    //                let touchEventModel = MusicKeyTouchMessageModel.init(touchAddress: touchAddress, touchEventPoint: touch.location(in: self), lastTouchKey: pressedKey)
    //
    //                self.touchEventModelArray.append(touchEventModel)
    //
    //            }
    //
    //            // 如果点到按钮就触发通知
    //            if pressedKey != nil {
    //                pressedKey!.pressStatus = .Pressed
    //
    //                // 判断点击是否为上层按钮
    //                if let lowerLevelKeyIndex = self.judgeKeyIsHigherLevelKey(pressedKey!.mainKey) {
    //                    self.musicKeyArray[lowerLevelKeyIndex].pressStatus = .Pressed
    //
    //                }
    //            }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let touchAddress = String(format: "%p",  touch)
            
            
            for touchEventView in touchEventViewArray {
                if touchEventView.touchAddress == touchAddress {
                    touchEventView.movementDirectionPoint = touch.location(in: self)
                    
                }
                
            }
            
            
            
            //            let previousPressedKey = self.lastTouchKeyDict[touchAddress]!
            
            // 上次点击的按钮
            //            let previousPressedKey: BaseMusicKey? = self.getLastTouchKey(address: touchAddress)
            //
            //
            //
            //            // 本次点击的按钮
            //            let pressedKey = self.judgeTouchMusicKey(touch.location(in: self))
            //
            //
            //            // 本次点击的按钮不为空
            //            if pressedKey != nil {
            //
            //                // 判断点击是否为上层按钮
            //                if let lowerLevelKeyIndex = self.judgeKeyIsHigherLevelKey(pressedKey!.mainKey) {
            //                    self.musicKeyArray[lowerLevelKeyIndex].pressStatus = .Pressed
            //
            //                }
            //
            //
            //                // 上次点击的按钮不为空
            //                if previousPressedKey != nil {
            //
            //                    // 两次点击的按钮不一致
            //                    if pressedKey!.mainKey != previousPressedKey!.mainKey {
            //
            //                        previousPressedKey!.pressStatus = .Unpressed
            //
            //
            //                        // 判断是否从上层Key滑动到下层Key
            //                        if self.judgeKeyIsMoved(fromHigherLevelKey: previousPressedKey!, toLowerLevelKey: pressedKey!) == false {
            //
            //                            pressedKey!.pressStatus = .Pressed
            //                        }
            //
            //                    }
            //
            //                }else {
            //                    pressedKey!.pressStatus = .Pressed
            //
            //                }
            //
            //
            //
            //            }else {
            //                // 上次点击的按钮不为空
            //                if previousPressedKey != nil {
            //                    previousPressedKey!.pressStatus = .Unpressed
            //
            //                }
            //            }
            //
            ////            self.lastTouchKeyDict[touchAddress]! = pressedKey
            //
            //            let _ = self.judgeTouchAddress(address: touchAddress, key: pressedKey)
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let touchAddress = String(format: "%p",  touch)
            
            for touchEventView in touchEventViewArray {
                if touchEventView.touchAddress == touchAddress {
                    touchEventView.touchAddress = ""
                    
                }
                
            }
            
            if self.presentTouchArray.contains(touch) == true {
                
                var index = 0
                for recordTouch in self.presentTouchArray {
                    let recordTouchAddress = String(format: "%p",  recordTouch)
                    
                    if recordTouchAddress == touchAddress {
                        self.presentTouchArray.remove(at: index)
                        
                    }
                    
                    index += 1
                }
                
            }
            
            //            let lastKey = self.lastTouchKeyDict[touchAddress]!
            //            let lastKey = self.getLastTouchKey(address: touchAddress)
            //
            //            if lastKey != nil {
            //                lastKey!.pressStatus = .Unpressed
            //
            //            }
            
            //            self.lastTouchKeyDict.removeValue(forKey: touchAddress)
            
        }
        
        self.resetMovableMusicKeyLocation()
        
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for touch in touches {
            
            let touchAddress = String(format: "%p",  touch)
            
            
            for touchEventView in touchEventViewArray {
                if touchEventView.touchAddress == touchAddress {
                    touchEventView.touchAddress = ""
                    
                    
                }
                
                if self.presentTouchArray.contains(touch) == true {
                    
                    var index = 0
                    for recordTouch in self.presentTouchArray {
                        let recordTouchAddress = String(format: "%p",  recordTouch)
                        
                        if recordTouchAddress == touchAddress {
                            self.presentTouchArray.remove(at: index)
                            
                        }
                        
                        index += 1
                    }
                    
                }
                
            }
            
            
            //            let lastKey = self.lastTouchKeyDict[touchAddress]!
            //            let lastKey = self.getLastTouchKey(address: touchAddress)
            //
            //            if lastKey != nil {
            //                lastKey!.pressStatus = .Unpressed
            //
            //            }
            
            //            self.lastTouchKeyDict.removeValue(forKey: touchAddress)
            
        }
        
        
        self.resetMovableMusicKeyLocation()
    }
}

// MARK: - 关于点击区域的判断
extension OperateKeysView {
    /// 抬起时重置可拖动音乐键的位置
    private func resetMovableMusicKeyLocation() -> Void {
        for musicKey in self.musicKeyArray {
            if musicKey.kind == .Movable {
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: [],
                    animations: {
                        musicKey.frame = (musicKey as! BaseMovableMusicKey).initialFrame
                        
                },
                    completion: nil
                )
                musicKey.pressStatus = .Unpressed
                
            }
        }
    }
    
    
    
    
    /// 遍历touch事件模型 并比对touch是否为同一条轨迹
    //    private func judgeTouchAddress(address: String, key: BaseMusicKey?) -> Bool {
    //        for model in self.touchEventModelArray {
    //            if model.touchAddress == address {
    //                model.lastTouchKey = key
    //
    //                return true
    //            }
    //
    //        }
    //
    //        return false
    //    }
    //
    /// 通过touch地址返回最后一个点击的音乐键
    //    func getLastTouchKey(address: String) -> BaseMusicKey? {
    //        for model in self.touchEventModelArray {
    //            if model.touchAddress == address {
    //
    //                return model.lastTouchKey
    //
    //            }
    //
    //        }
    //
    //        return nil
    //    }
    
    
    
    /// 判断点击了哪个key
    private func judgeTouchMusicKey(_ touchPoint: CGPoint) -> BaseMusicKey? {
        
        var tmpMusicKeyArray: [BaseMusicKey] = []
        
        for musicKey in self.musicKeyArray {
            if musicKey.frame.contains(touchPoint) {
                tmpMusicKeyArray.append(musicKey)
                
            }
            
        }
        
        if tmpMusicKeyArray.count != 0 {
            return tmpMusicKeyArray.last!
        }
        
        return nil
    }// funcEnd
    
    /// 判断是否从上层Key滑动到下层Key [上层Key, 下层Key] -> Bool
    func judgeKeyIsMoved(fromHigherLevelKey: BaseMusicKey, toLowerLevelKey: BaseMusicKey) -> Bool {
        if let higherLevelKeyIndexArray = MusicKeyAttributesModel.StackKeysDict[toLowerLevelKey.mainKey] {
            
            if higherLevelKeyIndexArray.contains(fromHigherLevelKey.mainKey) {
                return true
            }
            
        }
        
        return false
    }// funcEnd
    
    /// 用Index判断是否为上层按钮 如果是上层按钮 返回其底层按钮Index
    func judgeKeyIsHigherLevelKey(_ keyIndex: Int) -> Int? {
        for lowerLevelKeyIndex in MusicKeyAttributesModel.StackKeysDict.keys {
            let higherLevelKeyIndexArray = MusicKeyAttributesModel.StackKeysDict[lowerLevelKeyIndex]!
            
            if higherLevelKeyIndexArray.contains(keyIndex) == true {
                
                return lowerLevelKeyIndex
            }
            
            
        }
        
        return nil
        
    }// funcEnd
    
}

extension OperateKeysView: TouchEventViewDelegate {
    func doWithDetermineTrack(oldPoint: CGPoint, newPoint: CGPoint) {
        for musicKey in self.musicKeyArray {
            let isPassed = ToolClass.judgeTwoPointsSegmentIsPassView(point1: oldPoint, point2: newPoint, view: musicKey)
            
            if isPassed == true {
                musicKey.pressStatus = .Pressed
                
//                if musicKey.kind == .Movable {
//                    UIView.animate(
//                        withDuration: 0.25,
//                        delay: 0,
//                        options: [],
//                        animations: {
//                            musicKey.center = newPoint
//                    },
//                        completion: nil
//                    )
//                    
//                    
//                }
            }
        }
        
        
        
    }
    
}

// MARK: - 外部赋值之后
extension OperateKeysView {
    func didSetRecognizedPointArray(_ recognizedPointArray: [CGPoint?]) -> Void {
        
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = false
        }
        
        for index in 0 ..< 17 {
            
            DispatchQueue.main.async {
                
                if let point = recognizedPointArray[index] {
                    
//                    self.touchEventViewArray[index].isHidden = false
                    self.touchEventViewArray[index].movementDirectionPoint = point
                    
                }
//                else {
//                    self.touchEventViewArray[index].isHidden = true
//
//                }
                
            }
        }
        
        
            

        
//        var recordLeftHandPoint: CGPoint? = nil
//        var recordRightHandPoint: CGPoint? = nil
//
//        if let leftHandPoint = recognizedPointArray[0]{
//            DispatchQueue.main.async {
//                self.touchEventViewArray[0].movementDirectionPoint = leftHandPoint
//
//            }
//
//            recordLeftHandPoint = leftHandPoint
//
//        }else {
//            if self.prevRecognizedPointArray[0] == nil {
//                recordLeftHandPoint = nil
//
//            }else {
//                let tmpPoint = CGPoint.init(
//                    x: CGFloat.random(in: 20 ..< ToolClass.getScreenWidth() - 20),
//                    y: CGFloat.random(in: 20 ..< ToolClass.getScreenHeight() - 20)
//                )
//
//                self.touchEventViewArray[0].movementDirectionPoint = tmpPoint
//
//                recordLeftHandPoint = tmpPoint
//            }
//
//        }
//
//        if let rightHandPoint = recognizedPointArray[1]{
//            DispatchQueue.main.async {
//                self.touchEventViewArray[1].movementDirectionPoint = rightHandPoint
//
//            }
//
//            recordRightHandPoint = rightHandPoint
//
//        }else {
//            if self.prevRecognizedPointArray[1] == nil {
//                recordRightHandPoint = nil
//
//            }else {
//                let tmpPoint = CGPoint.init(
//                    x: CGFloat.random(in: 20 ..< ToolClass.getScreenWidth() - 20),
//                    y: CGFloat.random(in: 20 ..< ToolClass.getScreenHeight() - 20)
//                )
//
//                self.touchEventViewArray[1].movementDirectionPoint = tmpPoint
//
//                recordRightHandPoint = tmpPoint
//            }
//
//        }
//
//        self.prevRecognizedPointArray = [recordLeftHandPoint, recordRightHandPoint]
        
        
        
//        switch recognizedPointArray.count {
//        case 1:
//            let point = recognizedPointArray.first!
//
//            DispatchQueue.main.async {
//                if self.touchEventViewArray[1].isHidden == true { // 屏幕上只有一个点直接吸附
//                    let touchEventView = self.touchEventViewArray[0]
//                    touchEventView.movementDirectionPoint = point
//
//                }else { // 屏幕上有两个点 选择其中最近的吸附
//                    var distanceArray: [CGFloat] = []
//
//                    for touchEventView in self.touchEventViewArray {
//                        let touchEventViewToTouch = ToolClass.getDistance(point1: point, point2: touchEventView.center)
//
//                        distanceArray.append(touchEventViewToTouch)
//                    }
//
//                    if distanceArray[0] < distanceArray[1] {
//                        self.touchEventViewArray[0].movementDirectionPoint = point
//
//                    }else {
//                        self.touchEventViewArray[1].movementDirectionPoint = point
//
//                    }
//
//                }
//            }
//
//        default:
//            for point in recognizedPointArray {
//                DispatchQueue.main.async {
//                    let distanceToFirst = ToolClass.getDistance(
//                        point1: self.touchEventViewArray[0].center,
//                        point2: point
//                    )
//
//                    let distanceToSecond = ToolClass.getDistance(
//                        point1: self.touchEventViewArray[1].center,
//                        point2: point
//                    )
//
//                    let touchEventDistanceModel = TouchEventRecordDistance.init(
//                        targetTouch: nil, targetPoint: point,
//                        distanceToFirstBall: distanceToFirst,
//                        distanceToSecondBall: distanceToSecond
//                    )
//
//                    touchEventDistanceModelArray.append(touchEventDistanceModel)
//                }
//            }
//
//            if touchEventDistanceModelArray.count == 0 {
//
//                self.Signage = true
//
//                return
//
//            }
//
//            print(touchEventDistanceModelArray.count)
//
//            let queueGroupA = DispatchGroup.init()
//            let queueA = DispatchQueue.init(label: "tmpAQueue")
//
//            queueA.async(group: queueGroupA, execute: {
//                touchEventDistanceModelArray.sort { (modelA, modelB) -> Bool in
//                    return modelA.distanceToFirstBall < modelB.distanceToFirstBall
//                }
//            })
//
//            queueGroupA.notify(queue: DispatchQueue.main) {
//                let nearestTouchModelToFirst = touchEventDistanceModelArray[0]
//
//                self.touchEventViewArray[0].movementDirectionPoint = nearestTouchModelToFirst.targetPoint!
//            }
//
//            DispatchQueue.main.async {
//                if self.touchEventViewArray[1].isHidden == false {
//
//                    let queueGroupB = DispatchGroup.init()
//                    let queueB = DispatchQueue.init(label: "tmpBQueue")
//                    queueB.async(group: queueGroupB, execute: {
//
//                        touchEventDistanceModelArray.sort { (modelA, modelB) -> Bool in
//                            return modelA.distanceToSecondBall < modelB.distanceToSecondBall
//                        }
//                    })
//
//                    if touchEventDistanceModelArray.count == 0 {
//                        return
//                    }
//
//                    queueGroupB.notify(queue: DispatchQueue.main) {
//                        let nearestTouchModelToSecond = touchEventDistanceModelArray[0]
//                        self.touchEventViewArray[1].movementDirectionPoint = nearestTouchModelToSecond.targetPoint!
//                    }
//
//
//                }
//            }
//
//        }
//
////        objc_sync_exit(self.touchEventViewArray)
//        self.Signage = true
    }
    
}
