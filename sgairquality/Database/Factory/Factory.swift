//
//  Database.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import GRDB

enum DatabaseFactory {
    static func makePool(at path: String) throws -> DatabasePool {
        var config = GRDB.Configuration()
        config.readonly = false
        config.foreignKeysEnabled = true
        config.label = "SGAirQualityDB: \((path as NSString).lastPathComponent)"
        config.busyMode = .timeout(2.0)
        let pool = try DatabasePool(path: path, configuration: config)
        try pool.writeWithoutTransaction { db in
            try db.execute(sql: "PRAGMA journal_mode=WAL")
            try db.execute(sql: "PRAGMA synchronous=NORMAL")
        }

        return pool
    }
}
