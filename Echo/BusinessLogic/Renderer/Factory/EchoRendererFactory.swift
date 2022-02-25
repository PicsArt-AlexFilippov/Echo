//
//  EchoRendererFactory.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit

/// Factory what builds rendered for echo effect
public protocol EchoRendererFactory: AnyObject {
    /// Creates renderer to handle metal textures and play sounds
    /// - Parameters:
    /// - metalDevice common MTLDevice instance
    /// - directionMap Map contains audio URLs for different direction
    /// - Returns: rendered for echo effect
    func makeRenderer(metalDevice: MTLDevice,
                      directionMap: [Direction: URL]) -> EchoRenderer?
}
