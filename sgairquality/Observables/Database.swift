//
//  Database.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import GRDB
import os.log

@Observable
final class Database {
    
    static let shared = Database()
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sgairquality", category: "Database")
    
    let dbWriter: any DatabaseWriter
    
    private init() {
        do {
            self.dbWriter = try DatabaseFactory.makePool(at: Database.getDatabaseDirectory().appending(components: "database.sqlite").path())
            try runMigrations(self.dbWriter)
            Self.logger.debug("Created database and ran migrations")
            Self.logger.debug("Database is located at: \(try! Database.getDatabaseDirectory(), privacy: .private)")
        } catch {
            Self.logger.error("Failed to create database \(error.localizedDescription)")
            fatalError("Failed to initialise database")
        }
    }
    
    private static func getDatabaseDirectory() throws -> URL {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError.init(.fileDoesNotExist)
        }
        
        let databaseDirectory = documentDirectory.appending(component: "data")
        
        if !fileManager.fileExists(atPath: databaseDirectory.path()) {
            try fileManager.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
        }
        
        return databaseDirectory
    }
    
    func runMigrations(_ writer: any DatabaseWriter) throws {
        let migrator = DatabaseMigrations.makeMigrator()
        try migrator.migrate(writer)
    }
    
    /// Saves a PM25 record to the database
    /// - Parameter record: The PM25Record to save
    /// - Throws: Database errors if the save operation fails
    /// - Note: If a record with the same timestamp already exists, the record is replaced in full
    func save(_ record: PM25Record) throws {
        try dbWriter.write { db in
            try record.insert(db, onConflict: .replace)
            Self.logger.debug("Saved PM25 Record")
        }
    }
    
    /// Saves a PSI record to the database
    /// - Parameter record: The PSIRecord to save
    /// - Throws: Database errors if the save operation fails
    /// - Note: If a record with the same timestamp already exists, the record is replaced in full
    func save(_ record: PSIRecord) throws {
        try dbWriter.write { db in
            try record.insert(db, onConflict: .replace)
            Self.logger.debug("Saved PSI Record")
        }
    }

    
}
