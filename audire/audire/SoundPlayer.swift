//
//  SoundPlayer.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/08/19.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

protocol SoundPlayerDelegate: class {
    func updateMessage(text: String)
    func updatePlayBtnsTitle(text: String)
}

class SoundPlayer: NSObject, AVAudioPlayerDelegate {
    
    weak var delegate: SoundPlayerDelegate? = nil
    
    var audioPlayer = AVAudioPlayer()
    
    var playingUrl:URL?
    
    var hasInit:Bool!
    
    // OSLog のインスタンスを生成して
    let log = OSLog(subsystem: "jp.classmethod.SampleMobileApp", category: "UI")
    
    override init()
    {

    }
    
    public func initPlayer(url: URL)
    {
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            
            // 再生用の機能をアクティブにする
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategorySoloAmbient) //AVAudioSessionCategoryPlayback) アプリを落としても再生するときPlayback
            try! session.setActive(true)
            
            os_log("init player", log: log, type: .default)
            playingUrl = url
            hasInit = true
        }catch{
            os_log("cannot init audioPlayer", log: log, type: .error)
            hasInit = false
        }
    }
    
    public func play(url: URL)
    {
        if url == getSoundURL() && audioPlayer.isPlaying {
            os_log("already has playing", log: log, type: .error)
            return
        }
        initPlayer(url: url)
        play()
    }
    
    public func play()
    {
        if !hasInit {
            return
        }
        os_log("play", log: log, type: .default)
        audioPlayer.play()
        self.delegate?.updatePlayBtnsTitle(text: "Stop")
    }
    
    public func stop()
    {
        os_log("stop", log: log, type: .default)
        audioPlayer.stop()
        self.delegate?.updatePlayBtnsTitle(text: "Play")
    }
    
    public func isPlaying() -> Bool
    {
        if playingUrl == nil
        {
            return false
        }
        return audioPlayer.isPlaying
    }
    
    public func getSoundURL() -> URL? //nilがはいることを保証する
    {
        return playingUrl
    }
    
    public func setVolume(volume: Float)
    {
        audioPlayer.volume = volume
    }
    
    //再生終了時の呼び出しメソッド
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        self.delegate?.updatePlayBtnsTitle(text: "Finish")
        os_log("finish to play", log: log, type: .default)
    }
    
    // デコード中にエラーが起きた時に呼ばれるメソッド
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?)
    {
        os_log("decoding error on audioPlayer", log: log, type: .default)
    }
}
