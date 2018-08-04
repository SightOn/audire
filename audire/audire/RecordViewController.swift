//
//  RecordViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/07/22.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: ViewController{

    @IBOutlet weak var button: UIButton!

    var audioRecorder:AVAudioRecorder!
    var filePath:String!
    var fileName:String!

    let dataManager = TemporaryDataManager()
    var soundPlayer:SoundPlayer!

    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        button.setTitle("録音開始", for: .normal)
        disactiveRecorder()
    }
    
    func disactiveRecorder()
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        fileName = "sound_" + getNowMonthDayString()+".wav"
        filePath = documentPath + "/" + fileName
        let url = URL(fileURLWithPath: filePath)

        // 録音の詳細設定
        let recordSetting : [String : AnyObject] = [
            AVFormatIDKey : UInt(kAudioFormatALaw) as AnyObject,
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject
        ]
        
        // 録音の機能をオフにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategorySoloAmbient)
        try! session.setActive(true)

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSetting)
        } catch {
            fatalError("cannot init AudioRecorder")
        }
    }

    func initRecorder()
    {
        // 録音ファイルを指定する
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        fileName = "sound_" + getNowDateString()+".wav"
        filePath = documentPath + "/" + fileName
        print(filePath)
        let url = URL(fileURLWithPath: filePath)

        // 再生と録音の機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord) //AVAudioSessionCategoryRecord これにすると音をフィードバックを使えるかわりに音声にノイズが入る
        try! session.setActive(true)

        // 録音の詳細設定
        let recordSetting : [String : AnyObject] = [
            AVFormatIDKey : UInt(kAudioFormatALaw) as AnyObject,
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject
        ]
        
        print("success init AudioRecorder")
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSetting)
        } catch {
            fatalError("cannot init AudioRecorder")
        }
    }

    //録音ボタンタップ
    @IBAction func buttonTapped(_ sender : Any) {
        //一時的にVOをオフ
        button.setTitle("録音中", for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        button.accessibilityLabel = ""
        button.accessibilityHint = ""
        //読み上げ中でなければこれで読み上げが録音にはいらない
        
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
            print("on haptic!")
        }
        
        isRecording=true;
        //録音開始
        print("start recording")
        initRecorder()
        showAlert()
    }
    
    func finishRecord(){
        // 押されたら実行したい処理
        print("finish recording")
        self.button.setTitle("録音終了", for: .normal)
        self.button.backgroundColor = UIColor(red: 198/255, green: 200/255, blue: 201/255, alpha: 1.0)
        //録音停止，データを一時保存
        self.audioRecorder.stop()
        self.saveRecordData()
        disactiveRecorder()
        //次画面への遷移
        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PostNavigation")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func showAlert() {
        // アラートを作成
        let alert = UIAlertController(
            title: "",
            message: "録音中",
            preferredStyle: .alert)//.actionSheet
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "録音終了", style: .default, handler: { action in
            self.finishRecord()
        }))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
        sleep(2)
        self.audioRecorder.record()
    }
    
    func saveRecordData()
    {
        dataManager.save(fileName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
