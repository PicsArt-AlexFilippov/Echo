//
//  EchoRendererImpl.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit

final class EchoRendererImpl: EchoRenderer {
    // MARK: - Dependencies
    private let directionMap: [Direction: URL]
    
    // MARK: - Life cycle
    init(directionMap: [Direction: URL]) {
        self.directionMap = directionMap
    }
    
    // MARK: - EchoRenderer
    func render(texture: MTLTexture) {
        
    }
}
