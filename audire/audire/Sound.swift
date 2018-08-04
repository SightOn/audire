//
//  Sound.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/08/06.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import Foundation
import RealmSwift

// Tagクラス
class Tag: Object {
    @objc dynamic var tagName: String = ""
}

// Tagクラス
class VoiceTag: Object {
    @objc dynamic var tagFilePath: String = ""
}

class Sound: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var sound_name: String = "" //sound_title
    @objc dynamic var file_path: String = "" //file_nameに修正
    @objc dynamic var user_id: Int = 0 //ログイン関連が必要？
    
    let tags = List<Tag>()
    let voice_tags = List<VoiceTag>()
    
    @objc dynamic var created_stamp: Date = NSDate() as Date
    @objc dynamic var updated_stamp: Date = NSDate() as Date
    
    @objc dynamic var is_test_data: Bool = false
    
    // データを保存
    func save() {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            if self.id == 0 { self.id = self.createNewId() }
            realm.add(self, update: true)
        } else {
            try! realm.write {
                if self.id == 0 { self.id = self.createNewId() }
                realm.add(self, update: true)
            }
        }
    }
    
    // 新しいIDを採番します
    fileprivate func createNewId() -> Int {
        let realm = try! Realm()
        return (realm.objects(type(of: self).self).sorted(byKeyPath: "id", ascending: false).first?.id ?? 0) + 1
    }
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // インデックスの設定
//    override static func indexedProperties() -> [String] {
//        return [""]
//    }
}
