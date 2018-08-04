//
//  RecordDataManager.swift
//  
//
//  Created by inatani soichiro on 2017/08/11.
//
//

import UIKit

class TemporaryDataManager {
    //singleton
    static let sharedInstance = TemporaryDataManager()
    fileprivate var filePath: String
    let userDefaults = UserDefaults.standard
    
    init()
    {
        userDefaults.register(defaults: ["DataStore": "default"])
        filePath = ""
    }
    
    open func save(_ fileName :String)
    {
        let userDefault = UserDefaults.standard
        userDefault.set(fileName, forKey: "Key") // キーを指定してオブジェクトを保存
    }
    
    open func load() -> String
    {
        return userDefaults.string(forKey: "Key")!
    }
    
    // Keyを指定して読み込み(使用イメージ)
    //let filePath: String = loadDataPath()
    
    open func clean()
    {
        userDefaults.removeObject(forKey: "Key")
    }
}
