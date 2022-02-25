//
//  EchoRenderer.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit

/// Protocol of echo renderer
public protocol EchoRenderer: AnyObject {
    /// Render texture to calc direction and intensity and play sound
    ///
    /// - Parameter texture: Texture to handle. After handle audio will play
    func render(texture: MTLTexture)
}
