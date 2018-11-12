//
//  Feels.swift
//  dumpsite
//
//  Created by Elisha Saylon on 11/12/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol FeelsSerializable {
    init?(dictionary: [String: Any])
}

struct Feels {
    var userId: String
    var trashcan: String
    var moodImage: String
    var content: String
    var timestamp: Timestamp
    
    var dictionary: [String: Any] {
        return [
            "userId": userId,
            "trashcan": trashcan,
            "moodImage": moodImage,
            "content": content,
            "timestamp": timestamp
        ]
    }
}

extension Feels: FeelsSerializable {
    init?(dictionary: [String: Any]) {
        guard let userId = dictionary["userId"] as? String,
            let trashcan = dictionary["trashcan"] as? String,
            let moodImage = dictionary["moodImage"] as? String,
            let content = dictionary["content"] as? String,
            let timestamp = dictionary["timestamp"] as? Timestamp else { return nil }
        
        self.init(userId: userId, trashcan: trashcan, moodImage: moodImage, content: content, timestamp: timestamp)
    }
}
