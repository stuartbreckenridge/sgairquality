//
//  PSIRecord.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import GRDB

struct PSIRecord: Codable, Identifiable, FetchableRecord, PersistableRecord {

    static let databaseTableName: String = "psi_readings"

    var id: Int?
    var timestamp: Date
    var updated_timestamp: Date
    var date: String

    // O3 Sub-index for each region
    var o3_sub_index_west: Int
    var o3_sub_index_east: Int
    var o3_sub_index_central: Int
    var o3_sub_index_south: Int
    var o3_sub_index_north: Int

    // NO2 One Hour Max for each region
    var no2_one_hour_max_west: Int
    var no2_one_hour_max_east: Int
    var no2_one_hour_max_central: Int
    var no2_one_hour_max_south: Int
    var no2_one_hour_max_north: Int

    // O3 Eight Hour Max for each region
    var o3_eight_hour_max_west: Int
    var o3_eight_hour_max_east: Int
    var o3_eight_hour_max_central: Int
    var o3_eight_hour_max_south: Int
    var o3_eight_hour_max_north: Int

    // PSI Twenty Four Hourly for each region
    var psi_twenty_four_hourly_west: Int
    var psi_twenty_four_hourly_east: Int
    var psi_twenty_four_hourly_central: Int
    var psi_twenty_four_hourly_south: Int
    var psi_twenty_four_hourly_north: Int

    // PM10 Twenty Four Hourly for each region
    var pm10_twenty_four_hourly_west: Int
    var pm10_twenty_four_hourly_east: Int
    var pm10_twenty_four_hourly_central: Int
    var pm10_twenty_four_hourly_south: Int
    var pm10_twenty_four_hourly_north: Int

    // PM10 Sub-index for each region
    var pm10_sub_index_west: Int
    var pm10_sub_index_east: Int
    var pm10_sub_index_central: Int
    var pm10_sub_index_south: Int
    var pm10_sub_index_north: Int

    // PM2.5 Twenty Four Hourly for each region
    var pm25_twenty_four_hourly_west: Int
    var pm25_twenty_four_hourly_east: Int
    var pm25_twenty_four_hourly_central: Int
    var pm25_twenty_four_hourly_south: Int
    var pm25_twenty_four_hourly_north: Int

    // SO2 Sub-index for each region
    var so2_sub_index_west: Int
    var so2_sub_index_east: Int
    var so2_sub_index_central: Int
    var so2_sub_index_south: Int
    var so2_sub_index_north: Int

    // PM2.5 Sub-index for each region
    var pm25_sub_index_west: Int
    var pm25_sub_index_east: Int
    var pm25_sub_index_central: Int
    var pm25_sub_index_south: Int
    var pm25_sub_index_north: Int

    // SO2 Twenty Four Hourly for each region
    var so2_twenty_four_hourly_west: Int
    var so2_twenty_four_hourly_east: Int
    var so2_twenty_four_hourly_central: Int
    var so2_twenty_four_hourly_south: Int
    var so2_twenty_four_hourly_north: Int

    // CO Eight Hour Max for each region
    var co_eight_hour_max_west: Int
    var co_eight_hour_max_east: Int
    var co_eight_hour_max_central: Int
    var co_eight_hour_max_south: Int
    var co_eight_hour_max_north: Int

    // CO Sub-index for each region
    var co_sub_index_west: Int
    var co_sub_index_east: Int
    var co_sub_index_central: Int
    var co_sub_index_south: Int
    var co_sub_index_north: Int

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let timestamp = Column(CodingKeys.timestamp)
        static let updatedTimestamp = Column(CodingKeys.updated_timestamp)
        static let date = Column(CodingKeys.date)

        // O3 Sub-index
        static let o3SubIndexWest = Column(CodingKeys.o3_sub_index_west)
        static let o3SubIndexEast = Column(CodingKeys.o3_sub_index_east)
        static let o3SubIndexCentral = Column(CodingKeys.o3_sub_index_central)
        static let o3SubIndexSouth = Column(CodingKeys.o3_sub_index_south)
        static let o3SubIndexNorth = Column(CodingKeys.o3_sub_index_north)

        // NO2 One Hour Max
        static let no2OneHourMaxWest = Column(CodingKeys.no2_one_hour_max_west)
        static let no2OneHourMaxEast = Column(CodingKeys.no2_one_hour_max_east)
        static let no2OneHourMaxCentral = Column(CodingKeys.no2_one_hour_max_central)
        static let no2OneHourMaxSouth = Column(CodingKeys.no2_one_hour_max_south)
        static let no2OneHourMaxNorth = Column(CodingKeys.no2_one_hour_max_north)

        // O3 Eight Hour Max
        static let o3EightHourMaxWest = Column(CodingKeys.o3_eight_hour_max_west)
        static let o3EightHourMaxEast = Column(CodingKeys.o3_eight_hour_max_east)
        static let o3EightHourMaxCentral = Column(CodingKeys.o3_eight_hour_max_central)
        static let o3EightHourMaxSouth = Column(CodingKeys.o3_eight_hour_max_south)
        static let o3EightHourMaxNorth = Column(CodingKeys.o3_eight_hour_max_north)

        // PSI Twenty Four Hourly
        static let psiTwentyFourHourlyWest = Column(CodingKeys.psi_twenty_four_hourly_west)
        static let psiTwentyFourHourlyEast = Column(CodingKeys.psi_twenty_four_hourly_east)
        static let psiTwentyFourHourlyCentral = Column(CodingKeys.psi_twenty_four_hourly_central)
        static let psiTwentyFourHourlySouth = Column(CodingKeys.psi_twenty_four_hourly_south)
        static let psiTwentyFourHourlyNorth = Column(CodingKeys.psi_twenty_four_hourly_north)

        // PM10 Twenty Four Hourly
        static let pm10TwentyFourHourlyWest = Column(CodingKeys.pm10_twenty_four_hourly_west)
        static let pm10TwentyFourHourlyEast = Column(CodingKeys.pm10_twenty_four_hourly_east)
        static let pm10TwentyFourHourlyCentral = Column(CodingKeys.pm10_twenty_four_hourly_central)
        static let pm10TwentyFourHourlySouth = Column(CodingKeys.pm10_twenty_four_hourly_south)
        static let pm10TwentyFourHourlyNorth = Column(CodingKeys.pm10_twenty_four_hourly_north)

        // PM10 Sub-index
        static let pm10SubIndexWest = Column(CodingKeys.pm10_sub_index_west)
        static let pm10SubIndexEast = Column(CodingKeys.pm10_sub_index_east)
        static let pm10SubIndexCentral = Column(CodingKeys.pm10_sub_index_central)
        static let pm10SubIndexSouth = Column(CodingKeys.pm10_sub_index_south)
        static let pm10SubIndexNorth = Column(CodingKeys.pm10_sub_index_north)

        // PM2.5 Twenty Four Hourly
        static let pm25TwentyFourHourlyWest = Column(CodingKeys.pm25_twenty_four_hourly_west)
        static let pm25TwentyFourHourlyEast = Column(CodingKeys.pm25_twenty_four_hourly_east)
        static let pm25TwentyFourHourlyCentral = Column(CodingKeys.pm25_twenty_four_hourly_central)
        static let pm25TwentyFourHourlySouth = Column(CodingKeys.pm25_twenty_four_hourly_south)
        static let pm25TwentyFourHourlyNorth = Column(CodingKeys.pm25_twenty_four_hourly_north)

        // SO2 Sub-index
        static let so2SubIndexWest = Column(CodingKeys.so2_sub_index_west)
        static let so2SubIndexEast = Column(CodingKeys.so2_sub_index_east)
        static let so2SubIndexCentral = Column(CodingKeys.so2_sub_index_central)
        static let so2SubIndexSouth = Column(CodingKeys.so2_sub_index_south)
        static let so2SubIndexNorth = Column(CodingKeys.so2_sub_index_north)

        // PM2.5 Sub-index
        static let pm25SubIndexWest = Column(CodingKeys.pm25_sub_index_west)
        static let pm25SubIndexEast = Column(CodingKeys.pm25_sub_index_east)
        static let pm25SubIndexCentral = Column(CodingKeys.pm25_sub_index_central)
        static let pm25SubIndexSouth = Column(CodingKeys.pm25_sub_index_south)
        static let pm25SubIndexNorth = Column(CodingKeys.pm25_sub_index_north)

        // SO2 Twenty Four Hourly
        static let so2TwentyFourHourlyWest = Column(CodingKeys.so2_twenty_four_hourly_west)
        static let so2TwentyFourHourlyEast = Column(CodingKeys.so2_twenty_four_hourly_east)
        static let so2TwentyFourHourlyCentral = Column(CodingKeys.so2_twenty_four_hourly_central)
        static let so2TwentyFourHourlySouth = Column(CodingKeys.so2_twenty_four_hourly_south)
        static let so2TwentyFourHourlyNorth = Column(CodingKeys.so2_twenty_four_hourly_north)

        // CO Eight Hour Max
        static let coEightHourMaxWest = Column(CodingKeys.co_eight_hour_max_west)
        static let coEightHourMaxEast = Column(CodingKeys.co_eight_hour_max_east)
        static let coEightHourMaxCentral = Column(CodingKeys.co_eight_hour_max_central)
        static let coEightHourMaxSouth = Column(CodingKeys.co_eight_hour_max_south)
        static let coEightHourMaxNorth = Column(CodingKeys.co_eight_hour_max_north)

        // CO Sub-index
        static let coSubIndexWest = Column(CodingKeys.co_sub_index_west)
        static let coSubIndexEast = Column(CodingKeys.co_sub_index_east)
        static let coSubIndexCentral = Column(CodingKeys.co_sub_index_central)
        static let coSubIndexSouth = Column(CodingKeys.co_sub_index_south)
        static let coSubIndexNorth = Column(CodingKeys.co_sub_index_north)
    }

}
