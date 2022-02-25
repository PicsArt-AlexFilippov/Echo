//
//  EchoRendererImpl.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import MetalKit
import MetalPerformanceShaders

final class EchoRendererImpl: EchoRenderer {
    // MARK: - Dependencies
    private let directionMap: [Direction: URL]
    
    // MARK: - Data
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    private let filter = EchoFilter()
    
    private var textureDescriptor: MTLTextureDescriptor?
    private var renderPassDescriptor: MTLRenderPassDescriptor?
    private var sampler: MTLSamplerState!
    private var samplerMirrored: MTLSamplerState!
    private var arrayTexture: MTLTexture?
    private var segmentationArrayTexture: MTLTexture?
    private var intermediateTexture: MTLTexture?
    private var positionInTexture: Int = 0
    private var segmentationLastTextureIndex: Int = 0
    private var cacheSize: Int = 1
    private var frameNumber: Int = 0
    private var time: Float = 0
    private var textureLoader: MTKTextureLoader?
    private var emptyTexture: MTLTexture?
    private var emptyTextureArray: MTLTexture?
    
    /// Metal pipeline state we use for rendering
    private var renderPipelineState: MTLRenderPipelineState?
    /// Metal pipeline state we use for computing
    private var computePipelineState: MTLComputePipelineState?
    private var computePipelineStates: [MTLComputePipelineState?] = []
    
    private var imageBytes = [UInt8](repeating: 0, count: 4 * 1920 * 1080)
    private var segmentationImageBytes = [UInt8](repeating: 0, count: 1920 * 1080)
    
    private var textureDetails = TextureDetails()
    
    private var vertexCoordBuffer: MTLBuffer!
    private var textCoordBuffer: MTLBuffer!

    private var maskInfo = MaskInfo()
    private var segmentationTexture: MTLTexture? = nil
    private var segmentation = Segmentation(mode: 2)
    private var videoSourceType: VideoSourceType = .camera
    
    private var multiSampleTexture: MTLTexture?
    private var textures = [MTLTexture]()
    
    // MARK: - Life cycle
    init?(metalDevice: MTLDevice,
          directionMap: [Direction: URL]) {
        self.device = metalDevice
        guard let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = commandQueue
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle(for: Self.self)) else {
            return nil
        }
        self.library = library
        self.directionMap = directionMap
        
        reInitializeRenderPipelineState()
    }
    
    // MARK: - EchoRenderer
    public func reInitializeRenderPipelineState() {
        textureDescriptor = nil
        renderPassDescriptor = nil
        arrayTexture = nil
        segmentationArrayTexture = nil
        intermediateTexture = nil
        positionInTexture = 0
        segmentationLastTextureIndex = 0
        cacheSize = filter.cacheSize
        frameNumber = 0
        time = 0

        textureLoader = MTKTextureLoader(device: device)
        
        let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        guard let emptyTexture = try? textureLoader?.newTexture(cgImage: UIImage.from(color: color).cgImage!,
                                                                options: [:]) else {
            return
        }
        self.emptyTexture = emptyTexture
        let textureDescriptor = emptyTexture.matchingDescriptor()
        textureDescriptor.textureType = .type2DArray
        emptyTextureArray = device.makeTexture(descriptor: textureDescriptor)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = filter.msaaCount
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = filter.needsAdditionalColorAttachment ? .depth32Float : .invalid
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
        
        renderPassDescriptor = initializeRenderPass()
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.supportArgumentBuffers = false
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)
        
        samplerDescriptor.sAddressMode = .mirrorRepeat
        samplerDescriptor.tAddressMode = .mirrorRepeat

        samplerMirrored = device.makeSamplerState(descriptor: samplerDescriptor)

        /**
         *  Vertex function to map the texture to the view controller's view
         */
        pipelineDescriptor.vertexFunction = library.makeFunction(name: filter.vertexFunctionName)
        /**
         *  Fragment function to display texture's pixels in the area bounded by vertices of `mapTexture` shader
         */
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: filter.fragmentFunctionName)
        
        guard let kernelFunction = library.makeFunction(name: "kernelShader") else {
            return
        }
        let kernelFunctions = filter.kernelFunctionNames.compactMap { (functionName) in
            library.makeFunction(name: functionName)
        }
        
        do {
            try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            try computePipelineState = device.makeComputePipelineState(function: kernelFunction)
            computePipelineStates = []
            for kernelFunction in kernelFunctions {
                let computePipelineStateCurrent = try device.makeComputePipelineState(function: kernelFunction)
                computePipelineStates.append(computePipelineStateCurrent)
            }
        }
        catch let err as NSError {
            print(err)
            assertionFailure("Failed creating a render state pipeline. Can't render the texture without one.")
            return
        }
    }
    
    private func initializeRenderPass() -> MTLRenderPassDescriptor? {
        if renderPassDescriptor == nil {
            let black = MTLClearColor(red: 0.0, green: 0.0,
                                      blue: 0.0, alpha: 1.0)
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = black
            renderPassDescriptor.colorAttachments[0].storeAction = filter.msaaCount > 1 ? .multisampleResolve : .store

            if filter.additionalColorAttachmentsCount > 0 {
                renderPassDescriptor.colorAttachments[1].loadAction = .clear
                renderPassDescriptor.colorAttachments[1].clearColor = black
                renderPassDescriptor.colorAttachments[1].storeAction = .store
            }
        }
        return renderPassDescriptor
    }
    
    private func audioRender(texture: MTLTexture, encoder: MTLRenderCommandEncoder) -> (intensity: Double, direction: Int) {
        arrayTexture = initializeTextureDescriptor(texture:texture)
        encoder.setFragmentBytes(&positionInTexture, length: MemoryLayout<UInt>.size, index: 0)
        overrideTextureInArray(texture: texture)
        positionInTexture = (positionInTexture + 1 ) % cacheSize
        
        motionField()
        
        guard let intermediateTexture = intermediateTexture else {
            return
        }
        let meanTexture = self.averageTexture(texture: intermediateTexture, width : 1, height : 1)
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        let region = MTLRegionMake2D(0, 0, 1, 1)
        meanTexture.getBytes(pixels, bytesPerRow: 8, from: region, mipmapLevel: 0)
        
        let r = Float(pixels[0]) / 255.0
        let g = Float(pixels[1]) / 255.0
        let sensitivity: Float = 0.0016
        let numTracks: Float = 3.0
        let length: Float = (r * r + g * g).squareRoot()
        let push = length < sensitivity ? 0.0 : 1.0 //intensity
        let angle = atan2(r, g) + Float.pi
        let choice = Int(angle / 2.0 / Float.pi * numTracks) //number of track that should be played
        return (intensity: push, direction: choice)
        
//        encoder.setFragmentSamplerState(textureDetails.mirroring ? samplerMirrored : sampler, index: 0)
//        encoder.setFragmentTexture(texture, index: 0)
//
//        encoder.setFragmentSamplerState(textureDetails.mirroring ? samplerMirrored : sampler, index: 0)
//        encoder.setVertexBuffer(vertexCoordBuffer, offset: 0, index: 0)
//        encoder.setVertexBuffer(textCoordBuffer, offset: 0, index: 1)
//        var orientation = textureDetails.orientation.rawValue
//        encoder.setVertexBytes(&orientation, length: MemoryLayout<Int>.size, index: 2)
//        encoder.setVertexBytes(&textureDetails.mirroring, length: MemoryLayout<Bool>.size, index: 3)
//        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
//        encoder.endEncoding()
    }
    
    private func getComputePipelineState(index: Int) -> MTLComputePipelineState? {
        return computePipelineStates.count > index ? computePipelineStates[index] : nil
    }
    
    private func motionField() {
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let computePipelineState = getComputePipelineState(index: 0),
            let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            return
        }
        //   commandBuffer.enqueue()
        
        encoder.setComputePipelineState(computePipelineState)
        encoder.setTexture(arrayTexture, index: 0)
        encoder.setTexture(intermediateTexture, index: 1)
        bindMaskData(encoder, type: .compute)
        
        encoder.setBytes(&positionInTexture, length: MemoryLayout<UInt>.size, index: 0)
        
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSize(width: (arrayTexture!.width + w - 1) / w, height: (arrayTexture!.height + h - 1) / h, depth: 1)
        
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
        commandBuffer.commit()
    }
    
    func bindMaskData(_ encoder: MTLCommandEncoder, type: RenderState = .fragment) {
        var bindBytesFunction: ( (UnsafeRawPointer, Int, Int) ->() )
        var bindBufferFunction: ( (MTLBuffer?, Int, Int) ->() )
        var bindTextureFunction: ( (MTLTexture?, Int) -> () )
        
        switch type {
        case .vertex:
            let renderEncoder = encoder as! MTLRenderCommandEncoder
            bindBytesFunction = renderEncoder.setVertexBytes
            bindBufferFunction = renderEncoder.setVertexBuffer
            bindTextureFunction = renderEncoder.setVertexTexture
        case .fragment:
            let renderEncoder = encoder as! MTLRenderCommandEncoder
            bindBytesFunction = renderEncoder.setFragmentBytes
            bindBufferFunction = renderEncoder.setFragmentBuffer
            bindTextureFunction = renderEncoder.setFragmentTexture
        case .compute:
            let computeEncoder = encoder as! MTLComputeCommandEncoder
            bindBytesFunction = computeEncoder.setBytes
            bindBufferFunction = computeEncoder.setBuffer
            bindTextureFunction = computeEncoder.setTexture
        }
        if maskInfo.texture == nil {
            maskInfo.mode = .off
            maskInfo.texture = emptyTexture
        }
        
        var data = maskInfo.data
        bindBytesFunction(&data, MemoryLayout<MaskData>.size, Int(MASK_DATA_INDEX))
        
        if let maskTexture = maskInfo.texture {
            bindTextureFunction(maskTexture, Int(MASK_TEXTURE_INDEX))
        }
        
        if let segmentationArrayTexture = segmentationArrayTexture {
            bindTextureFunction(segmentationArrayTexture, Int(SEGMENTATION_TEXTURE_INDEX))
            bindBufferFunction(segmentationLastTextureIndexBuffer, 0, Int(SEGMENTATION_LAST_TEXTURE_INDEX_INDEX))
        }
        bindBufferFunction(segmentationModeBuffer, 0, Int(SEGMENTATION_MODE_INDEX))
    }
    
    private func averageTexture(texture: MTLTexture,
                                width: Int,
                                height: Int) -> MTLTexture {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return texture
        }

        let meanFilter = MPSImageStatisticsMean(device: device)
        //Create new texture based on passed texture descriptor
        let descriptor = texture.matchingDescriptor()
        descriptor.width = width;
        descriptor.height = height;
        descriptor.usage = [.shaderRead, .shaderWrite]
        let outputTexture = device.makeTexture(descriptor: descriptor)
        meanFilter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: outputTexture!)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        return outputTexture ?? texture
    }
    
    private func overrideTextureInArray(texture: MTLTexture) {
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        
        texture.getBytes(&imageBytes, bytesPerRow: 4 * texture.width, from: region, mipmapLevel: 0)
        self.arrayTexture?.replace(region: region, mipmapLevel: 0, slice: Int(self.positionInTexture), withBytes: imageBytes, bytesPerRow: 4 * texture.width, bytesPerImage: imageBytes.count)
    }
    
    private func initializeTextureDescriptor(texture: MTLTexture) -> MTLTexture? {
        if textureDescriptor == nil {
            let textureDescriptor = texture.matchingDescriptor()
            self.textureDescriptor = textureDescriptor
            textureDescriptor.textureType = .type2DArray
            textureDescriptor.pixelFormat = .bgra8Unorm
            textureDescriptor.arrayLength = Int(filter.cacheSize)
            textureDescriptor.mipmapLevelCount = 1;
            textureDescriptor.sampleCount = 1
            self.arrayTexture = device.makeTexture(descriptor: textureDescriptor)
            
            let tempTexture = segmentationTexture ?? texture
            let segmentationTextureDescriptor = tempTexture.matchingDescriptor()
            segmentationTextureDescriptor.textureType = .type2DArray
            segmentationTextureDescriptor.pixelFormat = .r8Unorm
            segmentationTextureDescriptor.arrayLength = Int(filter.segmentationCacheSize)
            segmentationTextureDescriptor.mipmapLevelCount = 1;
            segmentationTextureDescriptor.sampleCount = 1
            if segmentation.mode == 2 {
                segmentationTextureDescriptor.width = 1
                segmentationTextureDescriptor.height = 1
            }
            self.segmentationArrayTexture = device.makeTexture(descriptor: segmentationTextureDescriptor)
            segmentationImageBytes = [UInt8](repeating: 0, count: segmentationTextureDescriptor.width * segmentationTextureDescriptor.height)

            var drawableSize = CGSize(width: textureDescriptor.height,
                                      height: textureDescriptor.width)
            if videoSourceType == .library && self.textureDetails.videoOrientation == .identityPortrait {
                drawableSize = CGSize(width: textureDescriptor.width,
                                      height: textureDescriptor.height)
            }
            
            // Upscale drawable size in case of low resolution
            if Int(drawableSize.width * drawableSize.height) < 1080 * 1920 {
                let coef = Int(sqrt( Float( 1920 * 1080 ) / Float( drawableSize.height * drawableSize.width)))
                drawableSize.width *= CGFloat(coef)
                drawableSize.height *= CGFloat(coef)
            }
            
            textureDetails.size = drawableSize
            updateColorAttachmentTexture(size: metalView.drawableSize)

            textureDetails.contentMode = metalView.contentMode
            
            imageBytes = [UInt8](repeating: 0, count: 4 * texture.width * texture.height)
            
            textures = [MTLTexture]()
            
            let descriptor = texture.matchingDescriptor()
            descriptor.usage = [.shaderRead, .shaderWrite]
            descriptor.pixelFormat = .rgba16Float

            intermediateTexture = device.makeTexture(descriptor: descriptor)
//                var textureWidth =
//                var textureHeight = 10
//                if (texture.width > texture.height) {
//                    textureHeight = Int(round(Float(textureWidth)/(Float(texture.width)/Float(texture.height))))
//                } else if (texture.width < texture.height) {
//                    textureWidth = Int(round(Float(textureHeight)/(Float(texture.height)/Float(texture.width))))
//                }
//                descriptor.width = textureWidth
//                descriptor.height = textureHeight
            
//                var tempTexture = device.makeTexture(descriptor: descriptor)
//                intermediateTexture = tempTexture!
            
            if filter.msaaCount > 1 && !filter.needsAdditionalColorAttachment {
                let desc = texture.matchingDescriptor()
                desc.width = Int(drawableSize.width)
                desc.height = Int(drawableSize.height)
                desc.sampleCount = filter.msaaCount
                desc.textureType = .type2DMultisample
                desc.storageMode = .private
                desc.usage = .renderTarget
                multiSampleTexture = device.makeTexture(descriptor: desc)
                renderPassDescriptor?.colorAttachments[0].texture = multiSampleTexture
            }
            
            if filter.additionalColorAttachmentsCount > 0 {
                let descriptor = texture.matchingDescriptor()
                descriptor.width = Int(drawableSize.width)
                descriptor.height = Int(drawableSize.height)
                intermediateTexture = device.makeTexture(descriptor: descriptor)
            }
        }
        return arrayTexture
    }
    
    // MARK: - EchoRenderer
    func render(texture: MTLTexture) {
        guard let commandBuffer = self.commandQueue.makeCommandBuffer(),
              let encoder = filter.additionalColorAttachmentsCount != 0 || (filter.msaaCount > 1 && !filter.needsAdditionalColorAttachment) ? commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) : commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor) else {
            return
        }
        let result = audioRender(texture: texture,
                                 encoder: MTLRenderCommandEncoder)
        let url = directionMap[result.direction]
        // play URL
    }
}
