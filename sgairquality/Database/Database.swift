//
//  Database.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import GRDB
import os.log

protocol AirQualityRepository: Sendable {
    func save(_ record: PM25Record) throws
    func save(_ record: PSIRecord) throws
}

final class Database: AirQualityRepository, @unchecked Sendable {

    static let shared = Database()
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sgairquality", category: "Database")

    let dbWriter: any DatabaseWriter

    private init() {
        do {
            self.dbWriter = try DatabaseFactory.makePool(at: Database.getDatabaseDirectory().appending(components: "database.sqlite").path(percentEncoded: false))
            try runMigrations(self.dbWriter)
            Self.logger.debug("Created database and ran migrations")
            try cleanupOldRecords()
            #if DEBUG
            Self.logger.debug("Database is located at: \(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path() ?? "")")
            #endif
        } catch {
            Self.logger.error("Failed to create database \(error.localizedDescription)")
            fatalError("Failed to initialise database")
        }
    }

    private static func getDatabaseDirectory() throws -> URL {
        let fileManager = FileManager.default
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw URLError.init(.fileDoesNotExist)
        }

        let databaseDirectory = appSupportDirectory.appending(component: "data")

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
    /// - Note: If a record with the same timestamp already exists, the record is upserted
    func save(_ record: PM25Record) throws {
        try dbWriter.write { db in
            try record.upsert(db)
            Self.logger.debug("Saved PM25 Record")
        }
    }

    /// Saves a PSI record to the database
    /// - Parameter record: The PSIRecord to save
    /// - Throws: Database errors if the save operation fails
    /// - Note: If a record with the same timestamp already exists, the record is upserted
    func save(_ record: PSIRecord) throws {
        try dbWriter.write { db in
            try record.upsert(db)
            Self.logger.debug("Saved PSI Record")
        }
    }

    /// Fetches PM25 records from the database
    /// - Parameters:
    ///   - limit: Maximum number of records to fetch. Defaults to 100.
    ///   - offset: Number of records to skip. Defaults to 0.
    /// - Returns: Array of PM25Record ordered by timestamp descending (newest first)
    /// - Throws: Database errors if the fetch operation fails
    func fetchPM25Records(limit: Int = 100, offset: Int = 0) throws -> [PM25Record] {
        try dbWriter.read { db in
            let records = try PM25Record
                .order(PM25Record.Columns.timestamp.desc)
                .limit(limit, offset: offset)
                .fetchAll(db)
            Self.logger.debug("Fetched \(records.count) PM25 records")
            return records
        }
    }

    /// Fetches PSI records from the database
    /// - Parameters:
    ///   - limit: Maximum number of records to fetch. Defaults to 100.
    ///   - offset: Number of records to skip. Defaults to 0.
    /// - Returns: Array of PSIRecord ordered by timestamp descending (newest first)
    /// - Throws: Database errors if the fetch operation fails
    func fetchPSIRecords(limit: Int = 100, offset: Int = 0) throws -> [PSIRecord] {
        try dbWriter.read { db in
            let records = try PSIRecord
                .order(PSIRecord.Columns.timestamp.desc)
                .limit(limit, offset: offset)
                .fetchAll(db)
            Self.logger.debug("Fetched \(records.count) PSI records")
            return records
        }
    }

    /// Fetches PM25 records from the database within a time range
    /// - Parameter since: The start date of the range (records with timestamp >= this date are returned)
    /// - Returns: Array of PM25Record ordered by timestamp ascending (oldest first)
    /// - Throws: Database errors if the fetch operation fails
    func fetchPM25Records(since date: Date) throws -> [PM25Record] {
        try dbWriter.read { db in
            let records = try PM25Record
                .filter(PM25Record.Columns.timestamp >= date)
                .order(PM25Record.Columns.timestamp.asc)
                .fetchAll(db)
            Self.logger.debug("Fetched \(records.count) PM25 records since \(date)")
            return records
        }
    }

    /// Fetches PSI records from the database within a time range
    /// - Parameter since: The start date of the range (records with timestamp >= this date are returned)
    /// - Returns: Array of PSIRecord ordered by timestamp ascending (oldest first)
    /// - Throws: Database errors if the fetch operation fails
    func fetchPSIRecords(since date: Date) throws -> [PSIRecord] {
        try dbWriter.read { db in
            let records = try PSIRecord
                .filter(PSIRecord.Columns.timestamp >= date)
                .order(PSIRecord.Columns.timestamp.asc)
                .fetchAll(db)
            Self.logger.debug("Fetched \(records.count) PSI records since \(date)")
            return records
        }
    }

    /// Removes PM25 and PSI records older than 60 days
    /// - Throws: Database errors if the cleanup operation fails
    func cleanupOldRecords() throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date()

        try dbWriter.write { db in
            // Delete old PM25 records
            let pm25DeletedCount = try PM25Record
                .filter(PM25Record.Columns.timestamp < cutoffDate)
                .deleteAll(db)
            Self.logger.info("Deleted \(pm25DeletedCount) PM25 records older than 60 days")

            // Delete old PSI records
            let psiDeletedCount = try PSIRecord
                .filter(PSIRecord.Columns.timestamp < cutoffDate)
                .deleteAll(db)
            Self.logger.info("Deleted \(psiDeletedCount) PSI records older than 60 days")
        }
    }

}
