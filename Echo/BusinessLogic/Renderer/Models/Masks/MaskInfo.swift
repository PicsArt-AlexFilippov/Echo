//
//  MaskInfo.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit
import CoreGraphics

struct MaskPositionInfo {
    var scale: CGFloat = 1.0
    var angle: CGFloat = 0.0
    var origin = CGPoint(x: 0, y: 0)
    var size = CGSize(width: 0, height: 0)
}

enum MaskMode: Int {
    case off
    case on
    
    var description: String {
        get {
            return self == .on ? "mask.on" : "mask.off"
        }
    }
}

enum MaskInvertMode: Int {
    case off
    case on
    
    func boolValue() -> Bool {
        return self == .on ? true : false
    }
    
    var description: String {
        get {
            return self == .on ? "invert.on" : "invert.off"
        }
    }
}

final class MaskInfo {
    var mode = MaskMode.off {
        didSet {
            data.mode = Int32(mode.rawValue)
        }
    }
    var over = MaskInvertMode.off {
        didSet {
            data.over = Int32(over.rawValue)
        }
    }
    var type = MaskType.shape.maskTypeId() {
        didSet {
            data.type = Int32(type)
        }
    }
    var texture: MTLTexture?
    var position: MaskPositionInfo?
    private(set) var data = MaskData()
}
