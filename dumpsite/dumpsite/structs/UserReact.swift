//
//  UserReact.swift
//  dumpsite
//
//  Created by Elisha Saylon on 14/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol UserReactSerializable {
    init?(dictionary: [String: Any])
}

struct UserReact {
    var reactName: String
    var reactImage: String
    
    var dictionary : [String: Any] {
        return [
            "reactName": reactName,
            "reactImage": reactImage
        ]
    }
}

extension UserReact: UserReactSerializable {
    init?(dictionary: [String: Any]) {
        guard let reactName = dictionary["reactName"] as? String,
            let reactImage = dictionary["reactImage"] as? String else { return nil }
        
        self.init(reactName: reactName, reactImage: reactImage)
    }
}
