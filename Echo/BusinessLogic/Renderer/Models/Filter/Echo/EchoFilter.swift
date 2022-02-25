//
//  EchoFilter.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import Foundation

final class EchoFilter: Filter {
    
    override init() {
        super.init()
        self.name = "audio"
        self.kernelFunctionNames = ["motionField"]
        self.fragmentFunctionName = "Audio"
        self.needsCaching = true
        self.cacheSize = 4
    }
}

