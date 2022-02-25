//
//  EchoRendererFactory.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit

public protocol EchoRendererFactory: AnyObject {
    func makeRenderer(metalDevice: MTLDevice,
                      directionMap: [Direction: URL]) -> EchoRenderer?
}
