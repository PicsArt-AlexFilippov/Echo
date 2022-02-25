//
//  EchoRendererFactoryImpl.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

public final class EchoRendererFactoryImpl: EchoRendererFactory {
    // MARK: - Dependencies
    
    // MARK: - Life cycle
    init() {
        
    }
    
    // MARK: - EchoRendererFactory
    public func makeRenderer(directionMap: [Direction : URL]) -> EchoRenderer {
        return EchoRendererImpl(directionMap: directionMap)
    }
}
