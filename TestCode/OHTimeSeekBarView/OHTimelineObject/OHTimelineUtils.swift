//
//  OHTimelineUtils.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 18/5/24.
//

import Foundation

struct OHTimelineUtils {
    static func secondsSinceBeginningOfDay(from unixTimestamp: TimeInterval) -> Int {
        // Convert Unix timestamp to Date
        let date = Date(timeIntervalSince1970: unixTimestamp)
        // Get the current calendar
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        // Extract hour, minute, and second components from the date
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        // Calculate total seconds since beginning of the day
        let secondsSinceStartOfDay = (components.hour ?? 0) * 3_600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
        
        return secondsSinceStartOfDay
    }
    
    static func convertSecondsToHoursMinutesSeconds(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = seconds / 3_600
        let minutes = (seconds % 3_600) / 60
        let seconds = seconds % 60
        return (hours, minutes, seconds)
    }
    
    static func formatTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    static func timeIntervalSince1970ToMidnight(from unixTimestamp: TimeInterval) -> Int {
        // Convert Unix timestamp to Date
        let date = Date(timeIntervalSince1970: unixTimestamp)
        // Get the current calendar
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        // Create a new date representing midnight of the given date
        guard let midnightDate = calendar.date(from: components)
        else { return 0 }
        // Calculate the time interval since the Unix epoch (1970-01-01 00:00:00 UTC)
        let timeInterval = midnightDate.timeIntervalSince1970
        
        return Int(timeInterval)
    }
}
