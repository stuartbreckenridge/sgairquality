//
//  Database+Migrations.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import GRDB

enum DatabaseMigrations {

    static func makeMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1_base") { db in
            // PM2.5 readings table
            try db.create(table: "pm25_readings") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("timestamp", .datetime).notNull().indexed()
                t.column("updated_timestamp", .datetime).notNull()
                t.column("date", .text).notNull()

                // Regional PM2.5 one-hourly readings
                t.column("west", .integer).notNull()
                t.column("east", .integer).notNull()
                t.column("central", .integer).notNull()
                t.column("south", .integer).notNull()
                t.column("north", .integer).notNull()

                // Ensure we don't duplicate readings for the same timestamp
                t.uniqueKey(["timestamp"])
            }

            // PSI readings table
            try db.create(table: "psi_readings") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("timestamp", .datetime).notNull().indexed()
                t.column("updated_timestamp", .datetime).notNull()
                t.column("date", .text).notNull()

                // O3 Sub-index for each region
                t.column("o3_sub_index_west", .integer).notNull()
                t.column("o3_sub_index_east", .integer).notNull()
                t.column("o3_sub_index_central", .integer).notNull()
                t.column("o3_sub_index_south", .integer).notNull()
                t.column("o3_sub_index_north", .integer).notNull()

                // NO2 One Hour Max for each region
                t.column("no2_one_hour_max_west", .integer).notNull()
                t.column("no2_one_hour_max_east", .integer).notNull()
                t.column("no2_one_hour_max_central", .integer).notNull()
                t.column("no2_one_hour_max_south", .integer).notNull()
                t.column("no2_one_hour_max_north", .integer).notNull()

                // O3 Eight Hour Max for each region
                t.column("o3_eight_hour_max_west", .integer).notNull()
                t.column("o3_eight_hour_max_east", .integer).notNull()
                t.column("o3_eight_hour_max_central", .integer).notNull()
                t.column("o3_eight_hour_max_south", .integer).notNull()
                t.column("o3_eight_hour_max_north", .integer).notNull()

                // PSI Twenty Four Hourly for each region
                t.column("psi_twenty_four_hourly_west", .integer).notNull()
                t.column("psi_twenty_four_hourly_east", .integer).notNull()
                t.column("psi_twenty_four_hourly_central", .integer).notNull()
                t.column("psi_twenty_four_hourly_south", .integer).notNull()
                t.column("psi_twenty_four_hourly_north", .integer).notNull()

                // PM10 Twenty Four Hourly for each region
                t.column("pm10_twenty_four_hourly_west", .integer).notNull()
                t.column("pm10_twenty_four_hourly_east", .integer).notNull()
                t.column("pm10_twenty_four_hourly_central", .integer).notNull()
                t.column("pm10_twenty_four_hourly_south", .integer).notNull()
                t.column("pm10_twenty_four_hourly_north", .integer).notNull()

                // PM10 Sub-index for each region
                t.column("pm10_sub_index_west", .integer).notNull()
                t.column("pm10_sub_index_east", .integer).notNull()
                t.column("pm10_sub_index_central", .integer).notNull()
                t.column("pm10_sub_index_south", .integer).notNull()
                t.column("pm10_sub_index_north", .integer).notNull()

                // PM2.5 Twenty Four Hourly for each region
                t.column("pm25_twenty_four_hourly_west", .integer).notNull()
                t.column("pm25_twenty_four_hourly_east", .integer).notNull()
                t.column("pm25_twenty_four_hourly_central", .integer).notNull()
                t.column("pm25_twenty_four_hourly_south", .integer).notNull()
                t.column("pm25_twenty_four_hourly_north", .integer).notNull()

                // SO2 Sub-index for each region
                t.column("so2_sub_index_west", .integer).notNull()
                t.column("so2_sub_index_east", .integer).notNull()
                t.column("so2_sub_index_central", .integer).notNull()
                t.column("so2_sub_index_south", .integer).notNull()
                t.column("so2_sub_index_north", .integer).notNull()

                // PM2.5 Sub-index for each region
                t.column("pm25_sub_index_west", .integer).notNull()
                t.column("pm25_sub_index_east", .integer).notNull()
                t.column("pm25_sub_index_central", .integer).notNull()
                t.column("pm25_sub_index_south", .integer).notNull()
                t.column("pm25_sub_index_north", .integer).notNull()

                // SO2 Twenty Four Hourly for each region
                t.column("so2_twenty_four_hourly_west", .integer).notNull()
                t.column("so2_twenty_four_hourly_east", .integer).notNull()
                t.column("so2_twenty_four_hourly_central", .integer).notNull()
                t.column("so2_twenty_four_hourly_south", .integer).notNull()
                t.column("so2_twenty_four_hourly_north", .integer).notNull()

                // CO Eight Hour Max for each region
                t.column("co_eight_hour_max_west", .integer).notNull()
                t.column("co_eight_hour_max_east", .integer).notNull()
                t.column("co_eight_hour_max_central", .integer).notNull()
                t.column("co_eight_hour_max_south", .integer).notNull()
                t.column("co_eight_hour_max_north", .integer).notNull()

                // CO Sub-index for each region
                t.column("co_sub_index_west", .integer).notNull()
                t.column("co_sub_index_east", .integer).notNull()
                t.column("co_sub_index_central", .integer).notNull()
                t.column("co_sub_index_south", .integer).notNull()
                t.column("co_sub_index_north", .integer).notNull()

                // Ensure we don't duplicate readings for the same timestamp
                t.uniqueKey(["timestamp"])
            }
        }
        return migrator
    }
}
