//
//  ViewController.swift
//  LightSaberApp
//
//  Created by 山口仁志 on 2018/08/05.
//  Copyright © 2018年 LightSaberApp.hitoshi. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    
    // 加速度センサーを使うためのオブジェクトを格納します。
    let motionManager: CMMotionManager = CMMotionManager()
    
    // iPhoneを降った音を出すための再生オブジェクトを格納します。
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // ボタンを押した時の音を出すための再生オブジェクトを格納します。
    var startAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // 振っている最中かどうかの状態を格納します。
    // 降り始めるとtrue、降り終わるとfalseになります。
    var startAccel: Bool = false

    
    // アプリで使用する音の準備
    func setupSound() {
        // ボタンを押した時の音を設定します。
        if let sound = Bundle.main.path(forResource: "light_saber1", ofType: ".mp3") {
            startAudioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            startAudioPlayer.prepareToPlay()
        }
        
        // iPhoneを降った時の音を設定sます。
        if let sound = Bundle.main.path(forResource: "light_saber3", ofType: ".mp3") {
            audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            audioPlayer.prepareToPlay()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 音の準備
        setupSound()
    }

    @IBAction func tappedStartButton(_ sender: UIButton) {
        startAudioPlayer.play()
        startGetAccelerometer()
    }

    // 加速度センサーからの値取得の開始とその処理
    func startGetAccelerometer() {
        // 加速度センサーの検出間隔を指定
        motionManager.accelerometerUpdateInterval = 1 / 100

        // 検出開始と検出後の処理
        motionManager.startAccelerometerUpdates(to: OperationQueue.main)
        { (CMAccelerometerData: CMAccelerometerData?, error: Error?) in

            if let acc = CMAccelerometerData {
                // 各角度への合計速度を取得します。
                let x = acc.acceleration.x
                let y = acc.acceleration.y
                let z = acc.acceleration.z
                let synthetic = (x * x) + (y * y) + (z * z)

                // 一定以上の速度になったら音を鳴らします。
                if synthetic >= 8 {
                    
                    //振っている最中に音の再生が重複しないようにstartAccelをtrueにします。
                    self.startAccel = true
                    
                    // 音が再生中は重ねて再生できないので、再生開始位置に強制移動して最初から再生し直します。
                    self.audioPlayer.play()
                    self.audioPlayer.play()
                }
                
                // startAccelがtrue（降っている最中）かつ速度が一定以下になる（＝振るのをやめる）と
                // startAccelをfalseにして再び音がなるようにします。
                if self.startAccel == true && synthetic < 1 {
                    self.startAccel = false
                }
            }
        }
    }
    
}

