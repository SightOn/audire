//
//  ManualEditViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/07/22.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import AudioUnit
import AudioToolbox

class ManualEditViewController: ViewController {
    @IBOutlet weak var button: UIButton!
    let buttonLabel: [String] = ["オリジナル", "リバーブ1", "リバーブ2", "リバーブ3"]
    var buttonidx=0

    let temp_data = TemporaryDataManager()
    //var player: AVAudioPlayer?
    // インスタンス変数
    var engine = AVAudioEngine()
    //playerNodeの準備
    var player = AVAudioPlayerNode()
    //revebNodeの準備
    var reverb = AVAudioUnitReverb()
    //AVAudioUnitDelayの準備
    var delay = AVAudioUnitDelay()
    //その他の変数の準備
    var audiolength = 0
    var audioFormat = AVAudioFormat()
    //読み込みfile関係
    //let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    //let file_name = TemporaryDataManager().load()
    //var file_path: String! 仕様変更、上に書き直す
    let file_path = TemporaryDataManager().load()
    let fileUrl = URL(fileURLWithPath: TemporaryDataManager().load())

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        do {
            //print(fileUrl)
            let audioFile = try AVAudioFile(forReading: fileUrl)
            self.audioFormat = audioFile.processingFormat

            // reverbの設定
            reverb.loadFactoryPreset(.largeHall2)
            reverb.wetDryMix = 0
            
            //Delayの設定
            // 高域側のカットオフ周波数
            //audioFile.processingFormat.sampleRate
            delay.lowPassCutoff = 15000;    // Range: 10 -> (samplerate/2)
            delay.delayTime = 0;
            delay.feedback = 0;
            // AudioEngineにnodeを設定
            player.reset()
            engine.reset()
            engine.attach(player)
            engine.attach(reverb)
            engine.attach(delay)
            engine.connect(player, to: delay, format: audioFile.processingFormat)
            engine.connect(delay, to: reverb, format: audioFile.processingFormat)
            engine.connect(reverb, to: engine.outputNode, format: audioFile.processingFormat)
        } catch let error {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            //print(fileUrl)
            let audioFile = try AVAudioFile(forReading: fileUrl)
            self.audioFormat = audioFile.processingFormat
            // initializing the AVAudioPCMBuffer
            //let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: 1, interleaved: false)
            //let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)
            //try! audioFile.read(into: buf)
            
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            audiolength = Int(audioFrameCount)
            try! audioFile.read(into: audioFileBuffer!)
            engine.prepare()
            do{
                try! engine.start()
            }
            // playerにオーディオファイルを設定
            /*self.player.scheduleFile(audioFile, at: nil, completionHandler: { () -> Void in
             // 再生が終了すると呼ばれる
             print("Completion")
             })*/
            self.player.scheduleBuffer(audioFileBuffer!, at: nil, options:.loops, completionHandler: { () -> Void in
                // 再生が終了すると呼ばれる
                //print("Completion")
            })
            
            // 再生開始
            self.player.play()
        } catch let error {
            print(error)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoPost(){
        let save_file_path = file_path
        let fileUrl_write = URL(fileURLWithPath: save_file_path)
        //print(fileUrl_write)
        var goFlag=false
        do{
            
            let audioFile_write = try AVAudioFile(forWriting: fileUrl_write, settings: audioFormat.settings)
            reverb.installTap(onBus: 0, bufferSize: AVAudioFrameCount(audiolength), format: audioFormat, block: {buffer, when in
                if Int(audioFile_write.length) < self.audiolength{//Let us know when to stop saving the file, otherwise saving infinitely
                    do{
                        try audioFile_write.write(from: buffer)
                        //print(audioFile_write.length)
                    }catch let error{
                        print("Buffer error", error)
                    }
                }else{
                    self.reverb.removeTap(onBus: 0)//if we dont remove it, will keep on tapping infinitely
                    //audioFile_write=nil
                    //print("Save done")
                    self.player.stop()
                    self.engine.stop()
                    goFlag = true;
                }
                
            })
        }catch let error {
            print("AVAudioFile error:", error)
        }
        while(!goFlag){
            usleep(200000)
        }
        
    }
    
    @IBAction func buttonTapped(_ sender : Any) {
        buttonidx += 1;
        if buttonidx>=buttonLabel.count{
            buttonidx=0;
        }
        button.setTitle(buttonLabel[buttonidx], for: .normal)
        switch buttonidx {
        case 0:
            reverb.wetDryMix = 0
        case 1:
            reverb.wetDryMix = 40
        case 2:
            reverb.wetDryMix = 70
        case 3:
            reverb.wetDryMix = 100
        default:
            reverb.wetDryMix = 0
        }

    }
    @objc func doubleTapped() {
        // do something cool here
      /*  print("ダブルタップ")
        buttonidx += 1;
        if buttonidx>=buttonLabel.count{
            buttonidx=0;
        }
        switch buttonidx {
        case 0:
            reverb.wetDryMix = 0
        case 1:
            reverb.wetDryMix = 40
        case 2:
            reverb.wetDryMix = 70
        case 3:
            reverb.wetDryMix = 100
        default:
            reverb.wetDryMix = 0
        }
        button.setTitle(buttonLabel[buttonidx], for: .normal)
 */
        //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
