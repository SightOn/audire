//
//  WebFeedElement.swift
//  audire
//
//  Created by 和家尚希 on 2018/08/26.
//  Copyright © 2018年 inai17ibar. All rights reserved.
//

import Foundation
struct WebFeedElement {
    var user: String
    var showText: String
    var dataPath: String
    var dictionary: [String: Any] {
        return [
            "user": user,
            "showText": showText,
            "dataPath": dataPath,
        ]
    }
}
extension WebFeedElement {
    
    init?(dictionary: [String : Any]) {
        
        var user = "unknown"
        if let value = dictionary["user"] {
            user = value as! String
        }
        guard let showText = dictionary["dataname"] as? String,
            let dataPath = dictionary["filepath"] as? String
            else { return nil }
        
        self.init(user: user,
                  showText: showText,
                  dataPath:dataPath)
    }
    
}
