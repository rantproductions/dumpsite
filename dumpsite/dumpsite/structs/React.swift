//
//  React.swift
//  dumpsite
//
//  Created by Elisha Saylon on 11/12/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol ReactSerializable {
    init?(dictionary: [String: Any])
}

struct React {
    var reactName: String
    var reactCount: Int
    var userIdList = [String]()
    
    var dictionary: [String: Any] {
        return [
            "reactName": reactName,
            "reactCount": reactCount,
            "userIdList": userIdList
        ]
    }
}

extension React: ReactSerializable {
    init?(dictionary: [String : Any]) {
        guard let reactName = dictionary["reactName"] as? String,
            let reactCount = dictionary["reactCount"] as? Int,
            let userIdList = dictionary["userIdList"] as? [String] else { return nil }
        
        self.init(reactName: reactName, reactCount: reactCount, userIdList: userIdList)
    }
}
