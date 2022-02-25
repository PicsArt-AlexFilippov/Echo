//
//  Segmentation.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import Foundation

class Segmentation {
    let mode: SegmentationMode
    private(set) var isReady: Bool = false
    
    var name: String {
        switch mode {
        case kSegmentationModeHuman:
            return "human"
        case kSegmentationModeAllButHuman:
            return "all_but_human"
        case kSegmentationModeOff:
            return "human_off"
        default:
            fatalError("Unexpected SegmentationMode \(mode)")
        }
    }

    init(mode: SegmentationMode) {
        self.mode = mode
    }

    func markReady() {
        isReady = true
    }
}
