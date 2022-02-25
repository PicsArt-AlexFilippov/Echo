//
//  EchoRendererFactoryImpl.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit

/// Implementation of echo renderer factory
public final class EchoRendererFactoryImpl: EchoRendererFactory {
    // MARK: - Dependencies
    
    // MARK: - Life cycle
    init() {
        
    }
    
    // MARK: - EchoRendererFactory
    public func makeRenderer(metalDevice: MTLDevice,
                             directionMap: [Direction : URL]) -> EchoRenderer? {
        return EchoRendererImpl(metalDevice: metalDevice,
                                directionMap: directionMap)
    }
}
