//
//  Reactions.swift
//  dumpsite
//
//  Created by Elisha Saylon on 11/12/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol ReactionsSerializable {
    init?(dictionary: [String: Any])
}

struct Reactions {
    var feelsId: String
    var reactions: [String: Any]
    var timestamp: Timestamp
    
    var dictionary: [String: Any] {
        return [
            "feelsId": feelsId,
            "reactions": reactions,
            "timestamp": timestamp
        ]
    }
}

extension Reactions: ReactSerializable {
    init?(dictionary: [String : Any]) {
        guard let feelsId = dictionary["feelsId"] as? String,
            let reactions = dictionary["reactions"] as? [String: Any],
            let timestamp = dictionary["timestamp"] as? Timestamp else { return nil }
        
        self.init(feelsId: feelsId, reactions: reactions, timestamp: timestamp)
    }
}
