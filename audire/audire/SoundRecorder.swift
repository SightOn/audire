//
//  SoundRecorder.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/10/28.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

protocol SoundRecorderDelegate: class {
    func updateMessage(text: String)
    func updatePlayBtnsTitle(text: String)
}

class SoundRecorder: NSObject, AVAudioPlayerDelegate {
    
    weak var delegate: SoundPlayerDelegate? = nil
    
    var audioRecorder = AVAudioRecorder()
    
    var recordingUrl:URL?
    
    var hasInit:Bool!
    
    // 録音の詳細設定
    let recordSetting : [String : AnyObject] = [
        AVFormatIDKey : UInt(kAudioFormatALaw) as AnyObject,
        AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
        AVEncoderBitRateKey : 16 as AnyObject,
        AVNumberOfChannelsKey: 2 as AnyObject,
        AVSampleRateKey: 44100.0 as AnyObject
    ]
    
    // OSLog のインスタンスを生成して
    let log = OSLog(subsystem: "sighton", category: "UI")
    
    override init()
    {
        
    }
    
    public func initRecorder(url: URL)
    {
        // 録音の機能をオフにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategorySoloAmbient)
        try! session.setActive(true)
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recordingUrl = url
            hasInit = true
        } catch {
            os_log("cannot init audioRecorder", log: log, type: .error)
            hasInit = false
        }
    }
    
    public func record(url: URL)
    {
        if url == getSoundURL() {
            os_log("already has playing", log: log, type: .error)
            return
        }
        initRecorder(url: url)
        record()
    }
    
    public func record()
    {
        if !hasInit {
            return
        }
        os_log("record", log: log, type: .default)
        audioRecorder.record()
        self.delegate?.updatePlayBtnsTitle(text: "Stop")
    }
    
    public func stop()
    {
        os_log("stop", log: log, type: .default)
        audioRecorder.stop()
        self.delegate?.updatePlayBtnsTitle(text: "Record")
    }
    
    public func isPlaying() -> Bool
    {
        if recordingUrl == nil
        {
            return false
        }
        return audioRecorder.isRecording
    }
    
    public func getSoundURL() -> URL? //nilがはいることを保証する
    {
        return recordingUrl
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
