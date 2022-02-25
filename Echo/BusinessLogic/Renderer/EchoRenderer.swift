//
//  EchoRenderer.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit

public protocol EchoRenderer: AnyObject {
    func render(texture: MTLTexture)
}
