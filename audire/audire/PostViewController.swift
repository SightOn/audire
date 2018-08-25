//
//  PostViewController.swift
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
import Firebase

class PostViewController: BaseViewController {
    @IBOutlet weak var Editbutton: UIButton!
    let buttonLabel: [String] = ["オリジナル", "リバーブ1", "リバーブ2", "リバーブ3"]
    var buttonidx=0
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var textfield: UINavigationBar!
    let temp_data = TemporaryDataManager()
    let database = DatabaseAccessManager()
    
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let file_name = TemporaryDataManager().Get()
    var file_path: String!
    
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
    var isEffected=false
    
    //firebase
    var db: Firestore!
    //let collection = Firestore.firestore().collection("restaurants")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // [END setup]
    }

    private func addDataToFirebase(fileName: String, dataName: String) {
        // [START add_ada_lovelace]
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil

        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // File located on disk
        let localFile = URL(string: "file://"+file_path)!
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("audios/"+fileName)
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
        
        //let fileUrl = URL(fileURLWithPath: file_path)
        ref = db.collection("users").addDocument(data: [
            "filename": fileName,
            "dataname": dataName,
            "filepath": file_path,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("[post] viewWillAppear")
        
        file_path = documentPath + "/" + TemporaryDataManager().Get()
        let fileUrl = URL(fileURLWithPath: file_path)
        
        //プレイヤーの初期化
        do {
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
        
        //再生の準備
        do {
            //print(fileUrl)
            let audioFile = try AVAudioFile(forReading: fileUrl)
            self.audioFormat = audioFile.processingFormat
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
            self.player.scheduleBuffer(audioFileBuffer!, at: nil, options:.loops, completionHandler: { () -> Void in
            })
            // 再生開始
            self.player.play()
        } catch let error {
            print(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.player.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func post()
    {
        if(isEffected){
            saveData()
        }
        let data_name = getNowMonthDayString()
        let file_name = temp_data.Get()
        database.CreateData(file_name, dataName: data_name, userId: 1, tags:[""], voiceTags: [""], createDate: Date())
        database.Add()
        temp_data.Clean()
        self.addDataToFirebase(fileName: file_name, dataName: data_name)
    }

    func saveData()
    {
        let save_file_path = file_path
        let fileUrl_write = URL(fileURLWithPath: save_file_path!)
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
                    self.player.stop()
                    self.engine.stop()
                    goFlag = true;
                }
                
            })
        }catch let error {
            print("AVAudioFile error:", error)
        }
        
        //処理待ちをしている？
        while(!goFlag){
            usleep(200000)
        }
    }
    
    //投稿ボタンをおしたとき
    @IBAction func buttonTapped(_ sender : Any)
    {
        postButton.accessibilityLabel = ""
        postButton.accessibilityHint = ""
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
            print("on haptic!")
        }

        //再生停止
        self.player.stop()
        //投稿


        //self.showPostAlert()
        self.voiceTagAlert()
    }
    
    @IBAction func dismissButtonTapped(_ sender : Any)
    {
        dismissButton.accessibilityLabel = ""
        dismissButton.accessibilityHint = ""
        
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
            print("on haptic!")
        }
        
        //一時データ削除
        temp_data.Clean()

        //再生停止
        self.player.stop()
        self.showDismissAlert()

    }
    
    @IBAction func editbuttonTapped(_ sender : Any)
    {
        buttonidx += 1;
        if buttonidx>=buttonLabel.count{
            buttonidx=0;
        }
        Editbutton.setTitle(buttonLabel[buttonidx], for: .normal)
        switch buttonidx {
        case 0:
            //音声読み上げ
            let talker = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: "オリジナル")
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            talker.speak(utterance)
            reverb.wetDryMix = 0
        case 1:
            //音声読み上げ
            let talker = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: "リバーブ1")
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            talker.speak(utterance)
            reverb.wetDryMix = 40
        case 2:
            //音声読み上げ
            let talker = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: "リバーブ2")
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            talker.speak(utterance)
            reverb.wetDryMix = 70
        case 3:
            //音声読み上げ
            let talker = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: "リバーブ3")
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            talker.speak(utterance)
            reverb.wetDryMix = 100
        default:
            reverb.wetDryMix = 0
        }
    }
    
    func voiceTagAlert() {
        // アラートを作成
        let alert = UIAlertController(
            title: "",
            message: "音声タグを追加しますか",
            preferredStyle: .alert)
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "追加する", style: .default, handler: { action in
            self.jumpVoiceTagActivity()
        }))
        alert.addAction(UIAlertAction(title: "追加しない", style: .default, handler: { action in
            //投稿処理
            self.post()
            self.showPostAlert()
        }))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPostAlert() {
        // アラートを作成
        let alert = UIAlertController(
            title: "",
            message: "保存しました",
            preferredStyle: .alert)
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "再生リストに戻る", style: .default, handler: { action in
            self.finishActivity()
        }))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDismissAlert() {
        // アラートを作成
        let alert = UIAlertController(
            title: "",
            message: "キャンセルしました",
            preferredStyle: .alert)
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "再生リストに戻る", style: .default, handler: { action in
            self.finishActivity()
        }))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    func jumpVoiceTagActivity(){
        //次画面への遷移
        let storyBoard : UIStoryboard = UIStoryboard(name: "Post", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VoiceTagNavigation")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func finishActivity(){
        //次画面への遷移
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.present(nextViewController, animated:true, completion:nil)
        //TODO: これだとTabBarControllerの先頭にしか飛べない
    }

}
