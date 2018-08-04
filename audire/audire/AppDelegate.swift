//
//  AppDelegate.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/07/22.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let database = DatabaseAccessManager()

    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let seedFilePath = Bundle.main.path(forResource: "Places", ofType: "realm")
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentDir: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let realmPath = documentDir.appendingPathComponent("default.realm")
        //print(documentDir)
        
        //var config: Realm.Configuration?
        
        var config: Realm.Configuration
        
        if (!FileManager().fileExists(atPath: realmPath))
        {
            try! FileManager().copyItem(atPath: seedFilePath!, toPath: realmPath)
            config = Realm.Configuration()
//                fileURL: NSURL(fileURLWithPath: realmPath),
//                readOnly: false,
//                schemaVersion: 0 )
            config.fileURL = URL(fileURLWithPath: realmPath)
            config.readOnly = false
            config.schemaVersion = 2

            // Generate 64 bytes of random data to serve as the encryption key
            //let key = NSMutableData(length: 64)!
            //SecRandomCopyBytes(kSecRandomDefault, key.length, UnsafeMutablePointer<UInt8>(key.mutableBytes))
            //config.encryptionKey = key
            
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = config
        }
        else{
            //Realmのマイグレーション
            config = Realm.Configuration(
                // 新しいスキーマバージョンを設定します。 これは以前に使用されたものよりも大きくなければなりません
                // version（以前にスキーマバージョンを設定していない場合、バージョンは0です）。
                //readOnly: true,
                //path: realmPath,
                schemaVersion: 2,
                
                //スキーマのバージョンが上記のものよりも低い/を開くときに自動的に呼び出されるブロックを設定する
                migrationBlock: { migration, oldSchemaVersion in
                    //まだ何も移行していないので、oldSchemaVersion == 0
                    if (oldSchemaVersion < 1) {
                        // Realmは新しいプロパティと削除されたプロパティを自動的に検出します
                        //そして自動的にディスク上のスキーマを更新する
                    }}
            )
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = config
        }
        
        //デフォルトのレルムに対してこの新しい設定オブジェクトを使用するようにRealmに指示します
        let realm = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        print(realm, "Realm")
        //print(config,"Realm Version")
        
        // ここに初期化処理を書く
        //setDefaultDataset() //Realmの登録内容の初期化
        
        //ドキュメントフォルダ内のファイルを調べる
        var fileNames: [String] {
            do {
                return try FileManager.default.contentsOfDirectory(atPath: documentPath)
            } catch {
                return []
            }
        }
//        for name in fileNames
//        {
//            print(name)
//        }
        
        return true
    }
    
    func setDefaultDataset()
    {
        database.deleteAll()
        
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        
        //古い順にいれる → Realmのデフォルトファイルを作る予定
        var audioPath = "washroom.wav" //Bundle.main.path(forResource: "washroom", ofType:"wav")!
        database.create_test(audioPath, dataName: "06月09日", userId: 1, tags: ["水", "癒やし"], voiceTags: [""], createDate: calendar.date(era: 1, year: 2017, month: 6, day: 9, hour: 20, minute: 26, second: 0, nanosecond: 0)!)
        database.add()
        
        audioPath = "akihabara_lunch.m4a" //Bundle.main.path(forResource: "akihabara_lunch", ofType:"m4a")!
        database.create_test(audioPath, dataName: "06月11日 秋葉原", userId: 1, tags: ["ランチ"], voiceTags: [""], createDate: calendar.date(era: 1, year: 2017, month: 6, day: 11, hour: 14, minute: 26, second: 0, nanosecond: 0)!)
        database.add()
        
        audioPath = "on_the_bridge.m4a" //Bundle.main.path(forResource: "on_the_bridge", ofType:"m4a")!
        database.create_test(audioPath, dataName: "06月11日 勝どき", userId: 1, tags: ["風"], voiceTags: [""], createDate: calendar.date(era: 1, year: 2017, month: 6, day: 11, hour: 19, minute: 26, second: 0, nanosecond: 0)!)
        database.add()
        
        audioPath = "ginza_east.m4a" //Bundle.main.path(forResource: "ginza_east", ofType:"m4a")!
        database.create_test(audioPath, dataName: "06月18日 東銀座", userId: 1, tags: ["話し声", "信号"], voiceTags: [""], createDate: calendar.date(era: 1, year: 2017, month: 6, day: 18, hour: 13, minute: 26, second: 0, nanosecond: 0)!)
        database.add()
        
        audioPath = "on_stair.m4a" //Bundle.main.path(forResource: "on_stair", ofType:"m4a")!
        database.create_test(audioPath, dataName: "06月20日 大崎", userId: 1, tags: ["階段"], voiceTags: [""], createDate: calendar.date(era: 1, year: 2017, month: 6, day: 10, hour: 11, minute: 26, second: 0, nanosecond: 0)!)
        database.add()
        
        audioPath = "yurakucho_muzhirusi.m4a" //Bundle.main.path(forResource: "yurakucho_muzhirusi", ofType:"m4a")!
        database.create_test(audioPath, dataName: "08月08日 有楽町", userId: 1, tags: ["お祭り", "夜"], voiceTags: [""], createDate: calendar.date(era: 1, year: 2017, month: 8, day: 8, hour: 20, minute: 26, second: 0, nanosecond: 0)!)
        database.add()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

