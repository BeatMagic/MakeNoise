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
            tmpArray.append(touchEventView)

        }

        return tmpArray
    }()
    
    private var prevMusicKeyClickCountArray: [Int] = Array.init(repeating: 0, count: 12)
    
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
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .Normal),
            MusicKeyViewModel.init(tmpRect, .Normal),
            
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            MusicKeyViewModel.init(tmpRect, .BorderVariable),
            
            MusicKeyViewModel.init(tmpRect, .Movable),
        ]
        
        
        let normalHeight: CGFloat = 40
        let normalWidth: CGFloat = ToolClass.getScreenWidth() - normalHeight
        let normalMargin: CGFloat = normalHeight / 2
        
        let startX: CGFloat = normalHeight / 2
        let startY: CGFloat = ToolClass.getScreenHeight() / 5
        var recordY: CGFloat = 0
        
        for index in 0 ..< self.musicKeyViewModelArray.count {
            let viewModel = self.musicKeyViewModelArray[index]
            
            switch index {
                
            case 0, 1:
                let typeOfWidth = (normalWidth - normalHeight) / 2
                let typeOfHeight = normalHeight / 2 * 3
                
                viewModel.ownFrame = CGRect.init(
                    x: normalHeight / 2 + CGFloat.init(index) * (typeOfWidth + normalHeight),
                    y: startY,
                    width: typeOfWidth,
                    height: typeOfHeight
                )
                
            case 2, 3, 4, 5:
                let presentY = startY + normalHeight / 2 * 3 + normalMargin * 3 / 2 + (CGFloat.init(index) - 2) * (normalMargin + normalHeight)
                
                viewModel.ownFrame = CGRect.init(
                    x: startX,
                    y: presentY,
                    width: normalWidth, height: normalHeight
                )
                
                recordY = presentY
                
            case 6:
                recordY = recordY + (normalMargin + normalHeight)
                viewModel.ownFrame = CGRect.init(
                    x: startX,
                    y: recordY,
                    width: normalWidth,
                    height: normalHeight * 3 / 2
                )
                
                
                
            case 7, 8, 9, 10:
                let typeOfX = startX * 2
                let typeOfY = startY + normalHeight / 2
                let typeOfHight = normalHeight * 2
                let typeOfWidth = (normalWidth - normalHeight) / 2 - normalHeight
                
                if index == 7 || index == 8 {
                    viewModel.ownFrame = CGRect.init(
                        x: typeOfX + (CGFloat.init(index) - 7) * (normalHeight * 2.7 + typeOfHight),
                        y: typeOfY,
                        width: typeOfWidth,
                        height: typeOfHight
                    )
                    
                }else {
                    viewModel.ownFrame = CGRect.init(
                        x: typeOfX + (CGFloat.init(index) - 9) * (normalHeight * 2.7 + typeOfHight),
                        y: recordY - normalHeight,
                        width: typeOfWidth,
                        height: typeOfHight
                    )
                    
                }
                
                
            // 可拖动
            case 11:
                viewModel.ownFrame = CGRect.init(
                    x: (ToolClass.getScreenWidth() - normalHeight / 5 * 8) / 2,
                    y: recordY + normalHeight / 2,
                    width: normalHeight / 5 * 8,
                    height: normalHeight / 5 * 8
                )
                
                
            default:
                print("走到这就是错")
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let touchAddress = String(format: "%p",  touch)
            
            
            for touchEventView in touchEventViewArray {
                if touchEventView.touchAddress == touchAddress {
                    touchEventView.movementDirectionPoint = touch.location(in: self)
                    
                }
                
            }
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
        
        if oldPoint == CGPoint.init(x: ToolClass.getScreenWidth() / 2 - 15, y: ToolClass.getScreenHeight() / 2 - 15)  {
            
            return
        }
        
        for musicKey in self.musicKeyArray {
            
            let isPassed = ToolClass.judgeTwoPointsSegmentIsPassView(point1: oldPoint, point2: newPoint, view: musicKey)
            
            if isPassed == true && musicKey.frame.contains(oldPoint) == false {
                musicKey.pressStatus = .Pressed
                
            }
            
        }
        
    }
    
}

// MARK: - 外部赋值之后
extension OperateKeysView {
    func didSetRecognizedPointArray(_ recognizedPointArray: [CGPoint?]) -> Void {
        
        //        DispatchQueue.main.async {
        //            self.isUserInteractionEnabled = false
        //        }
        
        var tmpPointArray: [CGPoint?] = recognizedPointArray
        
        if tmpPointArray.count > 17 {
            
            for _ in 17 ..< tmpPointArray.count {
                tmpPointArray.removeLast()
            }
            
        }
        
        var musicKeyClickCountArray = Array.init(repeating: 0, count: self.musicKeyArray.count)
        
        for index in 0 ..< tmpPointArray.count {
            
            if let point = tmpPointArray[index] {
//                self.touchEventViewArray[index].movementDirectionPoint = point
                
                for musicKeyIndex in 0 ..< self.musicKeyArray.count {
                    let musicKey = self.musicKeyArray[musicKeyIndex]
                    DispatchQueue.main.async {
                        if musicKey.frame.contains(point){
                            musicKeyClickCountArray[musicKeyIndex] += 1
                            
                        }
                    }
                }
                
            }

        }
        
        
        
        for index in 0 ..< musicKeyClickCountArray.count {
            if musicKeyClickCountArray[index] > self.prevMusicKeyClickCountArray[index] {
//                print("+++++++")
//                print(self.prevMusicKeyClickCountArray[index])
//                print(musicKeyClickCountArray[index])
                
                self.musicKeyArray[index].pressStatus = .Pressed
                
            }
            
            print("index\(index) 个数\(musicKeyClickCountArray[index])")
            self.prevMusicKeyClickCountArray[index] = musicKeyClickCountArray[index]
        }
        
        
        
        
        //            DispatchQueue.main.async {
        //
        //                if let point = recognizedPointArray[index] {
        //                    self.touchEventViewArray[index].movementDirectionPoint = point
        //
        //                    for musicKey in self.musicKeyArray {
        //                        if musicKey.frame.contains(point){
        //
        //
        //                        }
        //                    }
        //                }
        //            }
    }
    
}
