//
//  OHTimelineGapTime.swift
//  TestCode
//
//  Created by Nguyen Tuan Anh on 18/5/24.
//

import Foundation

// Minute
enum OHTimelineGapTime: Int, CaseIterable {
    /* Case                 //  blocksPerHour */
    case one        = 1     //      60
    case five       = 5     //      12
    case ten        = 10    //      6
    case fifteen    = 15    //      4
    case thirty     = 30    //      2
    case sixty      = 60    //      1
    
    var blocksPerHour: Int {
        OHTimelineGapTime.sixty.rawValue / self.rawValue
    }
}
