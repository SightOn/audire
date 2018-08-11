//
//  DatabaseAccessManager.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/08/12.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import RealmSwift

class DatabaseAccessManager{
    //singleton
    static let sharedInstance = DatabaseAccessManager()
    var sound: Sound!
    
    //contructor
    init(){
        sound = Sound()
    }
    
    public func Add()
    {
        if sound.id == 0 {
            return
        }
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(sound)
            print("add on database, " + sound.file_path)
        }
    }
    
    public func CreateTestData(_ filePath: String, dataName: String, userId: Int, tags: [String], voiceTags: [String], createDate: Date)
    {
        sound = Sound()
        
        let tagsList = List<Tag>()
        for tag in tags {
            let newTag = Tag()
            newTag.tagName = tag
            tagsList.append(newTag)
        }
        
        let voiceTagsList = List<VoiceTag>()
        for tag in voiceTags {
            let newTag = VoiceTag()
            newTag.tagFilePath = tag
            voiceTagsList.append(newTag)
        }
        
        sound.file_path = filePath
        sound.sound_name = dataName
        sound.user_id = userId
        sound.tags.append(objectsIn: tagsList)
        sound.voice_tags.append(objectsIn: voiceTagsList)
        sound.created_stamp = createDate
        sound.updated_stamp = createDate
        sound.is_test_data = true
        
        sound.save()
    }
    
    public func CreateData(_ filePath: String, dataName: String, userId: Int, tags: [String], voiceTags: [String], createDate: Date)
    {
        sound = Sound()
        
        let tagsList = List<Tag>()
        for tag in tags {
            let newTag = Tag()
            newTag.tagName = tag
            tagsList.append(newTag)
        }
        
        let voiceTagsList = List<VoiceTag>()
        for tag in voiceTags {
            let newTag = VoiceTag()
            newTag.tagFilePath = tag
            voiceTagsList.append(newTag)
        }
        
        sound.file_path = filePath
        sound.sound_name = dataName
        sound.user_id = userId
        sound.tags.append(objectsIn: tagsList)
        sound.voice_tags.append(objectsIn: voiceTagsList)
        sound.created_stamp = createDate
        sound.updated_stamp = createDate
        sound.is_test_data = false
        
        sound.save()
    }
    
    //DBから読み込んで表示する場合
    public func ExtractByUserId(_ number: Int) -> Results<Sound>
    {
        let realm = try! Realm()
    
        let sortProperties = [SortDescriptor(keyPath: "created_stamp", ascending: false)]
        return realm.objects(Sound.self).filter("user_id == %@", number).sorted(by: sortProperties)
    }
    
    //DBの初期化
    public func DeleteAll()
    {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}
