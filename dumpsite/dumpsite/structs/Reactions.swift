//
//  Reactions.swift
//  dumpsite
//
//  Created by Elisha Saylon on 11/12/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation

protocol ReactionsSerializable {
    init?(dictionary: [String: Any])
}

struct Reactions {
    var reactions: [React]
    
    var dictionary: [String: Any] {
        return [
            "reactions": reactions
        ]
    }
}

extension Reactions: ReactSerializable {
    init?(dictionary: [String : Any]) {
        guard let reactions = dictionary["reactions"] as? [React] else { return nil }
        
        self.init(reactions: reactions)
    }
}
