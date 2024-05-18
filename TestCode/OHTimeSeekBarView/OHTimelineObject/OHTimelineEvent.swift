//
//  OHTimelineEvent.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 18/5/24.
//

import Foundation

struct OHTimelineEvent {
    let startUnixTimestamp: Int
    let endUnixTimestamp: Int
    
    var startTime: Int {
        OHTimelineUtils.secondsSinceBeginningOfDay(from: TimeInterval(startUnixTimestamp))
    }
    
    var endTime: Int {
        OHTimelineUtils.secondsSinceBeginningOfDay(from: TimeInterval(endUnixTimestamp))
    }
}
