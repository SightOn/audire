//
//  FeedViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/07/22.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import Firebase
class FeedViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, SoundPlayerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textfield: UIView!
    var soundPlayer :SoundPlayer!
    let database = DatabaseAccessManager()
    var realm: Realm!
    var sounds:Results<Sound>!
    
    private var mySections: NSArray = ["最近"]
    var limitedCellCount:Int! = 5 //20
    var refreshControl:UIRefreshControl!
    
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    //firestorage
    private var feedelements: [WebFeedElement] = []
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    private var listener: ListenerRegistration?
    var player = AVAudioPlayer()
    var beepplayer: AVAudioPlayer?
    
    
    fileprivate func observeQuery() {
        guard let query = query else { return }
        stopObserving()
        
        // Display data from Firestore, part one
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> WebFeedElement in
                if let model = WebFeedElement(dictionary: document.data()) {
                    return model
                } else {
                    // Don't use fatalError here in a real app.
                    fatalError("Unable to initialize type \(WebFeedElement.self) with dictionary \(document.data())")
                }
                
            }
            
            self.feedelements = models
            /*self.documents = snapshot.documents
            
            if self.documents.count > 0 {
                self.tableView.backgroundView = nil
            } else {
                self.tableView.backgroundView = self.backgroundView
            }
             */
            print(snapshot.documents)
            self.tableView.reloadData()
        }
        
    }
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("users").limit(to: 50)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //アクセスの許可
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,  self.textfield);
        //microphone access
        AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {(granted: Bool) in})
        
        // 引っ張ってロードの初期化
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(FeedViewController.onRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        query = baseQuery()
        

        do {
            if let fileURL = Bundle.main.path(forResource: "sign", ofType: "m4a") {
                self.beepplayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
    }
    
    //画面に来る度，毎回呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        observeQuery()

        realm = try! Realm()
        
        //データの読み出し，更新
        sounds = database.ExtractByUserId(1)
        soundPlayer = SoundPlayer()
        soundPlayer.delegate = self
        var seleted_url: URL
        if(sounds[0].is_test_data)
        {
            let path = sounds[0].file_path
            seleted_url = URL(fileURLWithPath: Bundle.main.path(forResource: path.components(separatedBy: ".")[0], ofType: path.components(separatedBy: ".")[1])!)
        }
        else
        {
            seleted_url = URL(fileURLWithPath: documentPath + "/" + sounds[0].file_path)
        }
        soundPlayer.InitPlayer(url: seleted_url)
        
        //Now reload the tableView
        self.tableView.reloadData()
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationController?.navigationBar.topItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        soundPlayer.Stop()
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedelements.count
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        _ = maximumOffset - currentOffsetY
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            //print("一番下に到達した時の処理")
            if(feedelements.count >= limitedCellCount + 5)
            {
                limitedCellCount = feedelements.count + 5
            }
            else
            {
                limitedCellCount = feedelements.count
            }
            tableView.reloadData()
        }
    }
    
    //セルのデータの読み出し
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedListItem") as! FeedListItemTableViewCell
            cell.titleLabel.text = feedelements[indexPath.row].showText;//sounds[indexPath.row].sound_name
            return cell
        }
        return UITableViewCell()
    }
    
    //あるセルを押したら再生
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //TODO get url and wav file from firebase, play them
        //database
        // Get a reference to the storage service using the default Firebase App
        let storageRef = Storage.storage().reference()
        var loadurl=feedelements[indexPath.row].fileName;
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("audios/"+loadurl)
        print(riversRef)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        riversRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("data load fail \(error.localizedDescription)")
            } else {
                // Data for "images/island.jpg" is returned
                print("loading data succeed.")
                do {
                    self.player = try AVAudioPlayer(data: data!)
                    self.player.prepareToPlay()
                    self.beepplayer?.play()
                    self.player.play()
                } catch {
                    NSLog("cannot play audio")
                }
            }
        }
/*        var seleted_url: URL
        if(sounds[indexPath.row].is_test_data)
        {
            let path = sounds[indexPath.row].file_path
            seleted_url = URL(fileURLWithPath: Bundle.main.path(forResource: path.components(separatedBy: ".")[0], ofType: path.components(separatedBy: ".")[1])!)
        }
        else
        {
            seleted_url = URL(fileURLWithPath: documentPath + "/" + sounds[indexPath.row].file_path)
        }
        let cell = tableView.cellForRow(at: indexPath) as! FeedListItemTableViewCell
        let voice_tag_url = URL(fileURLWithPath: documentPath + "/" + sounds[indexPath.row].voice_tags[0].tagFilePath)

        
        if (soundPlayer.GetSoundURL() == seleted_url)
        {
            //曲がセット済みのとき
            if soundPlayer.IsPlaying(){
                cell.titleLabel.accessibilityLabel = cell.titleLabel.text
                ttsStopSound()
                soundPlayer.Stop()
            }
            else{
                cell.titleLabel.accessibilityLabel = "再生中" //再生中の要素を示すため
                ttsPlaySound()
                
                //3秒の間ボイスタグを流して
                if(sounds[indexPath.row].voice_tags[0].tagFilePath != ""){
                    print("has voice tag")
                    soundPlayer.Play(url: voice_tag_url)
                    let dispatchTime = DispatchTime.now() + 3.0
                    DispatchQueue.main.asyncAfter( deadline: dispatchTime ) {
                        self.soundPlayer.Play(url: seleted_url)
                    }
                }else{
                    soundPlayer.Play(url: seleted_url)
                }
            }
        }
        else{
            let cells = tableView.visibleCells as! [FeedListItemTableViewCell]
            for cell_i in cells
            {
                cell_i.titleLabel.accessibilityLabel = cell_i.titleLabel.text
            }
            cell.titleLabel.accessibilityLabel = "再生中"
            ttsPlaySound()
            //3秒の間ボイスタグを流して
            if(sounds[indexPath.row].voice_tags[0].tagFilePath != "")
            {
                print("has voice tag")
                soundPlayer.Play(url: voice_tag_url)
                let dispatchTime = DispatchTime.now() + 3.0
                DispatchQueue.main.asyncAfter( deadline: dispatchTime ) {
                    self.soundPlayer.Play(url: seleted_url)
                }
            }else{
                soundPlayer.Play(url: seleted_url)
            }
        }
 */
        // 選択を常に解除しておく(解除しないほうが状態がわかりそう)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func ttsPlaySound()
    {
        let talker = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "再生")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        talker.speak(utterance)
        
        sleep(2)
    }
    
    private func ttsStopSound()
    {
        let talker = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "再生停止")
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        talker.speak(utterance)
        sleep(2)
    }
    
    func updateMessage(text: String){
    }
    
    func updatePlayBtnsTitle(text: String){
    }
    
    @objc func onRefresh(_ refreshControl: UIRefreshControl){
        /*self.refreshControl.beginRefreshing()
        if(sounds.count >= limitedCellCount + 5)
        {
            limitedCellCount = sounds.count + 5
        }
        else
        {
            limitedCellCount = sounds.count
        }
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        tableView.reloadData()
    }

}

