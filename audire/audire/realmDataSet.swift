//
//  realmDataSet.swift
//  Pods
//
//  Created by inatani soichiro on 2017/08/06.
//
//

import UIKit

//gloval val
struct RealmModel {
    struct realm{
        static var realmTry  = try!Realm()
        static var realmsset = realmDataSet()
        static var usersSet = RealmModel.realm.realmTry.objects(realmDataSet.self)
    }
}

class realmDataSet: Object {
    dynamic var now = NSDate()
    dynamic var hashId = String()
    dynamic var userName = String()
    dynamic var titleName = String()
    dynamic var tagName = String()
    dynamic var dataPath = String()
}
