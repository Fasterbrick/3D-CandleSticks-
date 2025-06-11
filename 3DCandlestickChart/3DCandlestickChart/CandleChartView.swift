// CandleChartView.swift
import SwiftUI
import MetalKit

struct CandleChartView: NSViewRepresentable {
    @ObservedObject var viewModel: CandleChartViewModel
    
    func makeNSView(context: Context) -> CustomMTKView {
        let mtkView = CustomMTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let device = mtkView.device else {
            fatalError("Metal is not supported on this device")
        }
        mtkView.delegate = context.coordinator
        context.coordinator.setup(
            device: device,
            viewModel: viewModel,
            metalView: mtkView
        )
        mtkView.coordinator = context.coordinator
        mtkView.clearColor = MTLClearColor(red: 0.85, green: 0.8, blue: 0.75, alpha: 1.0)
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.preferredFramesPerSecond = 120
        mtkView.autoResizeDrawable = true
        print("CustomMTKView created")
        return mtkView
    }
    
    func updateNSView(_ nsView: CustomMTKView, context: Context) {
        nsView.needsDisplay = true // Redraw if viewModel changes
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var depthState: MTLDepthStencilState!
        var vertexBuffer: MTLBuffer!
        var indexBuffer: MTLBuffer!
        var instanceBuffer: MTLBuffer!
        var depthTexture: MTLTexture?
        var stoneTexture: MTLTexture?
        var samplerState: MTLSamplerState? // Added sampler state property
        
        var cameraPosition = SIMD3<Float>(0, 2, 15)
        var cameraRotation = SIMD2<Float>(0, -.pi/6)
        
        let fov: Float = .pi/3
        let nearZ: Float = 0.1
        let farZ: Float = 100
        
        weak var mtkView: CustomMTKView?
            
            var lightDirection = normalize(SIMD3<Float>(0, 1, -1))
            
            func setup(device: MTLDevice, viewModel: CandleChartViewModel, metalView: CustomMTKView) {
                self.device = device
                self.commandQueue = device.makeCommandQueue()
                self.mtkView = metalView
                
                let textureLoader = MTKTextureLoader(device: device)
                if let textureURL = Bundle.main.url(forResource: "stone", withExtension: "png") {
                    do {
                        stoneTexture = try textureLoader.newTexture(URL: textureURL, options: nil)
                        print("Stone texture loaded successfully")
                    } catch {
                        print("Failed to load texture: \(error)")
                    }
                }
                
                let samplerDescriptor = MTLSamplerDescriptor()
                samplerDescriptor.minFilter = .linear
                samplerDescriptor.magFilter = .linear
                samplerDescriptor.mipFilter = .linear
                samplerDescriptor.sAddressMode = .repeat
                samplerDescriptor.tAddressMode = .repeat
                samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
                print("Sampler state created")
                
                vertexBuffer = device.makeBuffer(
                    bytes: viewModel.cubeVertices,
                    length: viewModel.cubeVertices.count * MemoryLayout<CandleChartViewModel.Vertex>.stride,
                    options: .storageModeShared
                )
                print("Vertex buffer length: \(vertexBuffer.length)")
                
                indexBuffer = device.makeBuffer(
                    bytes: viewModel.cubeIndices,
                    length: viewModel.cubeIndices.count * MemoryLayout<UInt16>.stride,
                    options: .storageModeShared
                )
                print("Index buffer length: \(indexBuffer.length)")
                
                instanceBuffer = device.makeBuffer(
                    bytes: viewModel.instanceData,
                    length: viewModel.instanceData.count * MemoryLayout<CandleChartViewModel.InstanceData>.stride,
                    options: .storageModeShared
                )
                print("Instance buffer length: \(instanceBuffer.length)")
                
                setupPipeline(metalView: metalView)
            }
        
        @MainActor
        func updateBuffers(viewModel: CandleChartViewModel) async {
            instanceBuffer = device.makeBuffer(
                    bytes: viewModel.instanceData,
                    length: viewModel.instanceData.count * MemoryLayout<CandleChartViewModel.InstanceData>.stride,
                    options: .storageModeShared
                )
                print("Instance buffer length: \(instanceBuffer?.length ?? 0)")
        }
        
        private func setupPipeline(metalView: MTKView) {
            guard let library = device.makeDefaultLibrary() else {
                fatalError("Failed to load Metal library")
            }
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].format = .float4 // position
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            
            vertexDescriptor.attributes[1].format = .float3 // normal
            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.size
            vertexDescriptor.attributes[1].bufferIndex = 0
            
            vertexDescriptor.attributes[2].format = .float2 // texCoord
            vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD4<Float>>.size + MemoryLayout<SIMD3<Float>>.size
            vertexDescriptor.attributes[2].bufferIndex = 0
            
            vertexDescriptor.layouts[0].stride = MemoryLayout<CandleChartViewModel.Vertex>.stride
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            print("Vertex descriptor set: \(pipelineDescriptor.vertexDescriptor != nil)")
            print("Pipeline depthAttachmentPixelFormat: \(pipelineDescriptor.depthAttachmentPixelFormat.rawValue)")
            
            let depthDescriptor = MTLDepthStencilDescriptor()
            depthDescriptor.isDepthWriteEnabled = true
            depthDescriptor.depthCompareFunction = .less
            depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
                print("Pipeline state created successfully")
            } catch {
                fatalError("Pipeline creation failed: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            updateDepthTexture(size: size)
        }
        
        private func updateDepthTexture(size: CGSize) {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .depth32Float,
                width: Int(size.width),
                height: Int(size.height),
                mipmapped: false
            )
            descriptor.usage = .renderTarget
            descriptor.storageMode = .private
            depthTexture = device.makeTexture(descriptor: descriptor)
        }
        
        func draw(in view: MTKView) {
                let drawableSize = view.drawableSize
                if depthTexture == nil || depthTexture!.width != Int(drawableSize.width) || depthTexture!.height != Int(drawableSize.height) {
                    updateDepthTexture(size: drawableSize)
                }
                
                if let pressedKeys = mtkView?.pressedKeys {
                    let moveSpeed: Float = 0.1 // 0.5 is too fast
                    let rotationMatrix = float4x4(rotationY: cameraRotation.x)
                    let forwardVec4 = rotationMatrix * SIMD4<Float>(0, 0, -1, 0)
                    let forward = SIMD3<Float>(forwardVec4.x, 0, forwardVec4.z)
                    let rightVec4 = rotationMatrix * SIMD4<Float>(1, 0, 0, 0)
                    let right = SIMD3<Float>(rightVec4.x, 0, rightVec4.z)
                    
                    if pressedKeys.contains(13) { cameraPosition += normalize(forward) * moveSpeed } // W
                    if pressedKeys.contains(1) { cameraPosition -= normalize(forward) * moveSpeed } // S
                    if pressedKeys.contains(124) { cameraPosition -= normalize(right) * moveSpeed } // Right
                    if pressedKeys.contains(123) { cameraPosition += normalize(right) * moveSpeed } // Left
                    if pressedKeys.contains(126) { cameraPosition.y += moveSpeed } // Up
                    if pressedKeys.contains(125) { cameraPosition.y -= moveSpeed } // Down
                }
                
                guard let drawable = view.currentDrawable,
                      let descriptor = view.currentRenderPassDescriptor,
                      let commandBuffer = commandQueue.makeCommandBuffer() else {
                    print("Failed to get drawable, descriptor, or command buffer")
                    return
                }
                
                guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                    print("Failed to create render encoder")
                    commandBuffer.commit()
                    return
                }
                
                guard let pipelineState = pipelineState,
                      let instanceBuffer = instanceBuffer,
                      let depthTexture = depthTexture else {
                    print("Failed to get pipeline state, instance buffer, or depth texture")
                    renderEncoder.endEncoding()
                    commandBuffer.commit()
                    return
                }
                
                descriptor.depthAttachment.texture = depthTexture
                descriptor.depthAttachment.loadAction = .clear
                descriptor.depthAttachment.storeAction = .dontCare
                descriptor.depthAttachment.clearDepth = 1.0
                
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setDepthStencilState(depthState)
                
                let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
                var projectionMatrix = float4x4(
                    perspectiveProjectionFov: fov,
                    aspect: aspectRatio,
                    near: nearZ,
                    far: farZ
                )
                
                var viewMatrix = float4x4(rotationX: cameraRotation.y) * float4x4(rotationY: cameraRotation.x)
                viewMatrix = viewMatrix * float4x4(translation: -cameraPosition)
                
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                renderEncoder.setVertexBytes(&viewMatrix, length: MemoryLayout<float4x4>.stride, index: 1)
                renderEncoder.setVertexBytes(&projectionMatrix, length: MemoryLayout<float4x4>.stride, index: 2)
                renderEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 3)
                
                renderEncoder.setFragmentBytes(&lightDirection, length: MemoryLayout<SIMD3<Float>>.stride, index: 0)
                if let stoneTexture = stoneTexture {
                    renderEncoder.setFragmentTexture(stoneTexture, index: 0)
                }
                if let samplerState = samplerState {
                    renderEncoder.setFragmentSamplerState(samplerState, index: 0)
                }
                
                renderEncoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                    indexType: .uint16,
                    indexBuffer: indexBuffer,
                    indexBufferOffset: 0,
                    instanceCount: instanceBuffer.length / MemoryLayout<CandleChartViewModel.InstanceData>.stride
                )
                
                renderEncoder.endEncoding()
                commandBuffer.present(drawable)
                commandBuffer.commit()
            }
        }
}

// MARK: - Input Handling Extension
extension CandleChartView.Coordinator {
    func handleDrag(delta: SIMD2<Float>) {
        let sensitivity: Float = 0.001
        cameraRotation.x += delta.x * sensitivity
        cameraRotation.y = clamp(
            value: cameraRotation.y + delta.y * sensitivity,
            min: -.pi/2,
            max: .pi/2
        )
    }
    
    func handleScroll(delta: Float) {
        let zoomSpeed: Float = 0.1
        cameraPosition.z = clamp(
            value: cameraPosition.z + delta * zoomSpeed,
            min: 1,
            max: 50
        )
    }
    
    private func clamp(value: Float, min: Float, max: Float) -> Float {
        return Swift.max(min, Swift.min(max, value))
    }
}

// MARK: - Custom MTKView Subclass with Key Tracking
class CustomMTKView: MTKView {
    var coordinator: CandleChartView.Coordinator?
    private var _pressedKeys: Set<UInt16> = []
    var pressedKeys: Set<UInt16> { return _pressedKeys }
    
    private var previousMousePosition: CGPoint?
    
    override var acceptsFirstResponder: Bool { true }
    
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        previousMousePosition = convert(event.locationInWindow, from: nil)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let previous = previousMousePosition else { return }
        let current = convert(event.locationInWindow, from: nil)
        let delta = SIMD2<Float>(
            Float(current.x - previous.x),
            Float(previous.y - current.y) // Invert Y-axis
        )
        coordinator?.handleDrag(delta: delta)
        previousMousePosition = current
        needsDisplay = true
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = Float(event.scrollingDeltaY)
        coordinator?.handleScroll(delta: delta)
        needsDisplay = true
    }
    
    override func keyDown(with event: NSEvent) {
        _pressedKeys.insert(event.keyCode)
    }
    
    override func keyUp(with event: NSEvent) {
        _pressedKeys.remove(event.keyCode)
    }
}
