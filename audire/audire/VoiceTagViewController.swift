//
//  VoiceTagViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/10/28.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceTagViewController: ViewController {
    
    @IBOutlet weak var recordButton: UIButton!

    var audioRecorder:AVAudioRecorder!
    var tag_file_name:String!
    var filePath:String!
    let temp_data = TemporaryDataManager()
    let database = DatabaseAccessManager()
    
    //let dataManager = TemporaryDataManager()
    var soundPlayer:SoundPlayer!
    var audioPlayer:AVAudioPlayer!
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recordButton.setTitle("音声タグの録音開始", for: .normal)
        disactiveRecorder()
    }
    
    func disactiveRecorder()
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        tag_file_name = "voice_tag_"+getNowDateString()+".wav"
        filePath = documentPath + "/"+tag_file_name
        let url = URL(fileURLWithPath: filePath)
        print(url as Any)
        
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
        tag_file_name = "voice_tag_"+getNowDateString()+".wav"
        filePath = documentPath + "/"+tag_file_name
        let url = URL(fileURLWithPath: filePath)
        
        // 再生と録音の機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        
        // 録音の詳細設定
        let recordSetting : [String : AnyObject] = [
            AVFormatIDKey : UInt(kAudioFormatALaw) as AnyObject,
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSetting)
        } catch {
            fatalError("cannot init AudioRecorder")
        }
    }
    
    //録音ボタンタップ
    @IBAction func buttonTapped(_ sender : Any) {
        startRecord()
    }
    func startRecord(){
        //一時的にVOをオフ
        recordButton.setTitle("録音中", for: .normal)
        recordButton.backgroundColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        recordButton.accessibilityLabel = ""
        recordButton.accessibilityHint = ""
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
    
    func showAlert() {
        // アラートを作成
        let alert = UIAlertController(
            title: "",
            message: "タグ録音中",
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
    
    func finishRecord(){
        // 押されたら実行したい処理
        print("finish recording")
        self.recordButton.setTitle("タグの録音終了", for: .normal)
        self.recordButton.backgroundColor = UIColor(red: 198/255, green: 200/255, blue: 201/255, alpha: 1.0)
        //録音停止，音声タグデータを保存
        self.audioRecorder.stop()
        do{
        try audioPlayer = AVAudioPlayer(contentsOf: self.audioRecorder.url)
            audioPlayer?.numberOfLoops = -1

            let seconds = 1.0//Time To Delay
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.audioPlayer?.play()
            })
            
        }catch{
            print("error in reading a file")
        }
        
        confirmationAlert()
    }
    
    func confirmationAlert() {
        // アラートを作成
        let alert = UIAlertController(
            title: "",
            message: "このタグでよろしいですか",
            preferredStyle: .alert)
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.audioPlayer?.stop()
            self.post() //順序に注意
            self.disactiveRecorder()
            //次画面への遷移
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(nextViewController, animated:true, completion:nil)
            
        }))
        alert.addAction(UIAlertAction(title: "取り直す", style: .default, handler: { action in
            self.audioPlayer?.stop()
            self.deleteTagFile()
            self.startRecord()
        }))
        alert.addAction(UIAlertAction(title: "タグをつけない", style: .default, handler: { action in
            self.audioPlayer?.stop()
            self.deleteTagFile()
            self.disactiveRecorder() //投稿もしていない
            //次画面への遷移
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(nextViewController, animated:true, completion:nil)
        }))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    //?
    func deleteTagFile(){
        do {
            let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: self.filePath) {
                // Delete file
                try fileManager.removeItem(atPath: filePath)
            } else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func post()
    {
        let file_name = temp_data.load()
        print()
        database.create(file_name, dataName: getNowMonthDayString(), userId: 1, tags:[""], voiceTags: [tag_file_name], createDate: Date())
        database.add()
        temp_data.clean()
    }
    
}
