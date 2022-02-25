//
//  EchoRendererFactory.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

public protocol EchoRendererFactory: AnyObject {
    func makeRenderer(directionMap: [Direction: URL]) -> EchoRenderer
}
