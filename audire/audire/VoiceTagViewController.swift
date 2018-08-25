//
//  VoiceTagViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/10/28.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class VoiceTagViewController: BaseViewController {
    
    @IBOutlet weak var recordButton: UIButton!

    var audioRecorder:AVAudioRecorder!
    var tag_file_name:String!
    var file_path:String!
    let temp_data = TemporaryDataManager()
    let database = DatabaseAccessManager()
    
    //let dataManager = TemporaryDataManager()
    var soundPlayer:SoundPlayer!
    var audioPlayer:AVAudioPlayer!
    var isRecording = false

    //firebase
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // [END setup]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recordButton.setTitle("音声タグの録音開始", for: .normal)
        disactiveRecorder()
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
    
    private func disactiveRecorder()
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        tag_file_name = "voice_tag_"+getNowDateString()+".wav"
        file_path = documentPath + "/"+tag_file_name
        let url = URL(fileURLWithPath: file_path)
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
    
    private func initRecorder()
    {
        // 録音ファイルを指定する
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        tag_file_name = "voice_tag_"+getNowDateString()+".wav"
        file_path = documentPath + "/"+tag_file_name
        let url = URL(fileURLWithPath: file_path)
        
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
    
    private func startRecord(){
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
    
    private func showAlert() {
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
    
    private func finishRecord(){
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
    
    private func confirmationAlert() {
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
    private func deleteTagFile(){
        do {
            let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: self.file_path) {
                // Delete file
                try fileManager.removeItem(atPath: file_path)
            } else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    private func post()
    {
        let data_name = getNowMonthDayString()
        let file_name = temp_data.Get()
        print()
        database.CreateData(file_name, dataName: data_name, userId: 1, tags:[""], voiceTags: [tag_file_name], createDate: Date())
        database.Add()
        temp_data.Clean()
        self.addDataToFirebase(fileName: file_name, dataName: data_name)
    }
    
}
