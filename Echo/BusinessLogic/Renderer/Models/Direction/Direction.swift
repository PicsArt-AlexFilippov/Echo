//
//  Direction.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import Foundation

public struct Direction: Hashable {
    let direction: Int
    let audioURL: URL
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(audioURL)
    }
}
