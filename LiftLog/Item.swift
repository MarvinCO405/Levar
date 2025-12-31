//
//  Item.swift
//  LiftLog
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
