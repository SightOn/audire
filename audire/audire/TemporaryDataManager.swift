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
    
    open func Set(_ fileName :String)
    {
        let userDefault = UserDefaults.standard
        userDefault.set(fileName, forKey: "Key") // キーを指定してオブジェクトを保存
    }
    
    open func Get() -> String
    {
        return userDefaults.string(forKey: "Key")!
    }
    
    open func Clean()
    {
        userDefaults.removeObject(forKey: "Key")
    }
}
