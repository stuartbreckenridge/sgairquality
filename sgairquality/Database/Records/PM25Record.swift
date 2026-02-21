//
//  PM25Record.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import GRDB

struct PM25Record: Codable, Identifiable, FetchableRecord, PersistableRecord {
    
    static let databaseTableName: String = "pm25_readings"
    
    var id: Int?
    var timestamp: Date
    var updated_timestamp: Date
    var date: String
    var west: Int
    var east: Int
    var central: Int
    var south: Int
    var north: Int
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let timestamp = Column(CodingKeys.timestamp)
        static let updatedTimestamp = Column(CodingKeys.updated_timestamp)
        static let date = Column(CodingKeys.date)
        static let west = Column(CodingKeys.west)
        static let east = Column(CodingKeys.east)
        static let central = Column(CodingKeys.central)
        static let south = Column(CodingKeys.south)
        static let north = Column(CodingKeys.north)
    }

}
