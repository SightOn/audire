//
//  AutoEditViewController.swift
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
//import Charts

class AutoEditViewController: ViewController {
    //let lmGenerator = OELanguageModelGenerator()
    let words = ["word", "Statement", "other word", "A PHRASE"] // These can be lowercase, uppercase, or mixed-case.
    let name = "NameIWantForMyLanguageModelFiles"
    //let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var sliderDelay: UISlider!
    @IBOutlet weak var waveChart: LineChartView!
    @IBOutlet weak var waveChartAutoEdit: LineChartView!
    @IBOutlet weak var updatebutton: UIButton!
    let temp_data = TemporaryDataManager()
    //var player: AVAudioPlayer?
    // インスタンス変数
    var engine = AVAudioEngine()
    //playerNodeの準備
    var player = AVAudioPlayerNode()
    //revebNodeの準備
    //var reverb = AVAudioUnitReverb()
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
        // 再生と録音の機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback) //SoloAmbient
        try! session.setActive(true)
        
        do {
            let audioFile = try AVAudioFile(forReading: fileUrl)
            audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            try! audioFile.read(into: audioFileBuffer)
            // this makes a copy, you might not want that
            let floatArray = Array(UnsafeBufferPointer(start: audioFileBuffer.floatChannelData?[0], count:Int(audioFileBuffer.frameLength)))
            var plotEntry = [ChartDataEntry]()
            audiolength = Int(audioFrameCount)
            for i in 0..<audiolength{
                if i%100==0{
                    let val = ChartDataEntry(x:Double(i)/audioFormat.sampleRate, y:Double(floatArray[i]))
                    plotEntry.append(val)
                }
            }
            let line1 = LineChartDataSet(values: plotEntry, label: "wave")
            line1.drawCirclesEnabled = false
            line1.colors = [NSUIColor.blue]
            let data = LineChartData()
            data.addDataSet(line1)
            waveChart.data = data
            waveChart.xAxis.drawGridLinesEnabled = false
            waveChart.leftAxis.drawLabelsEnabled = false
            waveChart.rightAxis.drawLabelsEnabled = false
            waveChart.chartDescription?.text = "raw wave"
            waveChart.legend.enabled = false
            print(audiolength)
            //Delayの設定
            // 高域側のカットオフ周波数
            //audioFile.processingFormat.sampleRate
            delay.lowPassCutoff = 4000;    // Range: 10 -> (samplerate/2)
            delay.delayTime = 0;
            delay.feedback = 0;
            // AudioEngineにnodeを設定
            engine.attach(player)
            engine.attach(delay)
            
            engine.connect(player, to: delay, format: audioFile.processingFormat)
            engine.connect(delay, to: engine.outputNode, format: audioFile.processingFormat)
            engine.prepare()
            do{
                try! engine.start()
            }
            // playerにオーディオファイルを設定
            /*self.player.scheduleFile(audioFile, at: nil, completionHandler: { () -> Void in
                // 再生が終了すると呼ばれる
                print("Completion")
            })*/
            self.player.scheduleBuffer(audioFileBuffer, at: nil, options:.loops,  completionHandler: { () -> Void in
                // 再生が終了すると呼ばれる
                print("[AutoEdit] Complete")
                })
            // 再生開始
            self.player.play()

          } catch let error {
           print(error)
        }
      
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        saveaudiofile_()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func buttonTapped(_ sender : Any) {
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
            print("on haptic!")
        }
        
        saveaudiofile_()
    }

    func saveaudiofile_(){
        //仕様変更あり
        let save_file_path = TemporaryDataManager().load()
        let fileUrl_write = URL(fileURLWithPath: save_file_path)
        //print(fileUrl_write)
        var goFlag=false
        do{
            let audioFile_write = try AVAudioFile(forWriting: fileUrl_write, settings: audioFormat.settings)
            delay.installTap(onBus: 0, bufferSize: AVAudioFrameCount(audiolength), format: audioFormat, block: {buffer, when in
                if Int(audioFile_write.length) < self.audiolength{//Let us know when to stop saving the file, otherwise saving infinitely
                    do{
                        try audioFile_write.write(from: buffer)
                        print(audioFile_write.length)
                    }catch let error{
                        print("Buffer error", error)
                    }
                }else{
                    self.delay.removeTap(onBus: 0)//if we dont remove it, will keep on tapping infinitely
                    //audioFile_write=nil
                    print("[AutoEdit] Save done")
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
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Post") as! PostViewController
        //nextViewController.currentControllerName = "AutoEdit"
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func sliderDelayChanged(sender: UISlider) {
        delay.lowPassCutoff = sliderDelay.value
        
    }
    @IBAction func updateButtonTapped(_ sender : Any) {
        var tmpArray = [Float]()
        var goFlag=false
        delay.installTap(onBus: 0, bufferSize: AVAudioFrameCount(audiolength), format: audioFormat, block: {buffer, when in
            if Int(tmpArray.count) < self.audiolength{//Let us know when to stop saving the file, otherwise saving infinitely
            tmpArray += Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)))
            print(tmpArray.count)
       
            }else{
                self.delay.removeTap(onBus: 0)//if we dont remove it, will keep on tapping infinitely
                goFlag = true;
            }
            
        })
        while(!goFlag){
            usleep(200000)
        }
        var plotEntry = [ChartDataEntry]()
        for i in 0..<audiolength{
            if i%100==0{
                let val = ChartDataEntry(x:Double(i)/audioFormat.sampleRate, y:Double(tmpArray[i]))
                plotEntry.append(val)
            }
        }
        let line1 = LineChartDataSet(values: plotEntry, label: "wave")
        line1.drawCirclesEnabled = false
        line1.colors = [NSUIColor.red]
        let data = LineChartData()
        data.addDataSet(line1)
        waveChartAutoEdit.data = data
        waveChartAutoEdit.xAxis.drawGridLinesEnabled = false
        waveChartAutoEdit.leftAxis.drawLabelsEnabled = false
        waveChartAutoEdit.rightAxis.drawLabelsEnabled = false
        waveChartAutoEdit.chartDescription?.text = "after edit wave"
        waveChartAutoEdit.legend.enabled = false
    }
    
    //????
    func doubleTapped() {
        // do something cool here
        print("ダブルタップ")
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
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
