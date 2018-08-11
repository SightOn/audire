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
    }
    
    //画面に来る度，毎回呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        //読み込み済みデータ数を返すべき
        if section == 0
        {
            return limitedCellCount
        }
        //通常はここに到達しない
        return 0
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        _ = maximumOffset - currentOffsetY
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            //print("一番下に到達した時の処理")
            if(sounds.count >= limitedCellCount + 5)
            {
                limitedCellCount = sounds.count + 5
            }
            else
            {
                limitedCellCount = sounds.count
            }
            tableView.reloadData()
        }
    }
    
    //セルのデータの読み出し
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedListItem") as! FeedListItemTableViewCell
            cell.titleLabel.text = sounds[indexPath.row].sound_name
            return cell
        }
        return UITableViewCell()
    }
    
    //あるセルを押したら再生
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var seleted_url: URL
        if(sounds[indexPath.row].is_test_data)
        {
            let path = sounds[indexPath.row].file_path
            print("test_data")
            seleted_url = URL(fileURLWithPath: Bundle.main.path(forResource: path.components(separatedBy: ".")[0], ofType: path.components(separatedBy: ".")[1])!)
        }
        else
        {
            print("my_data")
            seleted_url = URL(fileURLWithPath: documentPath + "/" + sounds[indexPath.row].file_path)
        }
        let cell = tableView.cellForRow(at: indexPath) as! FeedListItemTableViewCell
        let voice_tag_url = URL(fileURLWithPath: documentPath + "/" + sounds[indexPath.row].voice_tags[0].tagFilePath)

        print("select_sound: " , seleted_url as Any)
        print("select_voice_tag: " , voice_tag_url as Any)
        
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
