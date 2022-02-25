//
//  Filter.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import Foundation
import ARKit

class Filter: NSObject {
    var name: String!
    var needsCaching: Bool!
    internal var _cacheSize: Int! = 1
    var _segmentationCacheSize: Int = 1
    var segmentationCacheSize: Int {
        get {
            return _segmentationCacheSize
        }
        set {
            self._segmentationCacheSize = newValue
        }
    }
    private let maxFramesForFullHDWithSmallRAM = 70
    
    var cacheSize: Int {
        get {
            //If device RAM is less or equal to 3GB decrease cache size
            return _cacheSize
        }
        set {
            _cacheSize = newValue
        }
    }
    var needsPreprocessTexture: Bool! = false
    var requiresFeedbackTexture: Bool! = false
    var vertexFunctionName: String! = "vertexPassThrough"
    var fragmentFunctionName: String! = "fragmentPassThrough"
    var kernelFunctionNames: [String] = []
    var additionalColorAttachmentsCount: Int! = 0
    var msaaCount: Int! = 1
    var isNew: Bool! = false
    var segmentationBlurFactor: Float = 0.0
    var segmentationThresholdFactor: Float = 0.0
    var needsAdditionalColorAttachment = false
    var colorAttachmentFunctions: [String] = []
    var settings: [String: Any] = [:]
}
