//
//  PlayVideoViewController.swift
//  MakeNoise
//
//  Created by X Young. on 2018/9/30.
//  Copyright © 2018年 X Young. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayVideoViewController: UIViewController {
    
    var videoFileUrl: URL? = nil {
        didSet {
            let player = AVPlayer(url: self.videoFileUrl!)
            let playerLayer = AVPlayerLayer(player: player)
            
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
            
            player.play()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    @IBAction func backEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
