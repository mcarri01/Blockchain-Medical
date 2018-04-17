//
//  Constants.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/16/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import Foundation
import Firebase
struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseMessages = databaseRoot.child("messages")
    }
}
