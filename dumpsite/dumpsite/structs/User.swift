//
//  User.swift
//  dumpsite
//
//  Created by Elisha Saylon on 14/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol UserSerializable {
    init?(dictionary: [String: Any])
}

struct User {
    var userId: String
    var email: String
    var password: String
    var trashcanCount: Int
    var trashcans = [String]()
    
    var dictionary: [String: Any] {
        return [
            "userId": userId,
            "email": email,
            "password": password,
            "trashcanCount": trashcanCount,
            "trashcans": trashcans
        ]
    }
}

extension User: UserSerializable {
    init?(dictionary: [String: Any]) {
        guard let userId = dictionary["userId"] as? String,
            let email = dictionary["email"] as? String,
            let password = dictionary["password"] as? String,
            let trashcanCount = dictionary["trashcanCount"] as? Int,
            let trashcans = dictionary["trashcans"] as? [String] else { return nil }
        
        self.init(userId: userId, email: email, password: password, trashcanCount: trashcanCount, trashcans: trashcans)
    }
}
