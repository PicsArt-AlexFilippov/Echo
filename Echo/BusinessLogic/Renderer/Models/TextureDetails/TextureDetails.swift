//
//  TextureDetails.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import UIKit

class TextureDetails {
    var size: CGSize = CGSize.zero
    var orientation: Rotation = .rotate0Degrees
    var videoOrientation: VideoOrientation = .portraitVideoOrientation
    var mirroring: Bool = false
    var contentMode: UIView.ContentMode = .top
}

enum Rotation: Int {
    case rotate0Degrees = 0
    case rotate90Degrees = 90
    case rotate180Degrees = 180
    case rotate270Degrees = 270
}

enum VideoOrientation: Int {
    case portraitVideoOrientation
    case leftVideoOrientation
    case rightVideoOrientation
    case upVideoOrientation
    case downVideoOrientation
    case identityPortrait
}

enum RenderState: Int {
    case fragment
    case vertex
    case compute
}
