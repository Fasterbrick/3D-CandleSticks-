// CandleChartViewmodel.swift
import MetalKit
import simd

class CandleChartViewModel: ObservableObject {
    let candles: [Candle]
    let instanceData: [InstanceData]
    let cubeVertices: [Vertex]
    let cubeIndices: [UInt16]
    
    struct Vertex {
        let position: SIMD4<Float>
        let normal: SIMD3<Float>
        let texCoord: SIMD2<Float>
    }
    
    struct InstanceData {
        let modelMatrix: float4x4
        let color: SIMD4<Float>
    }
    
    init(candles: [Candle]) {
        self.candles = candles
        (self.cubeVertices, self.cubeIndices) = Self.createCubeGeometry()
        self.instanceData = Self.computeInstanceData(candles: candles)
        print("Instance data count: \(self.instanceData.count)")
    }
    
    private static func createCubeGeometry() -> ([Vertex], [UInt16]) {
        let vertices: [Vertex] = [
            // Front face (z = 0.5)
            Vertex(position: [-0.5, -0.5, 0.5, 1], normal: [0, 0, 1], texCoord: [0, 0]),
            Vertex(position: [0.5, -0.5, 0.5, 1], normal: [0, 0, 1], texCoord: [1, 0]),
            Vertex(position: [0.5, 0.5, 0.5, 1], normal: [0, 0, 1], texCoord: [1, 1]),
            Vertex(position: [-0.5, 0.5, 0.5, 1], normal: [0, 0, 1], texCoord: [0, 1]),

            // Back face (z = -0.5)
            Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [0, 0, -1], texCoord: [0, 0]),
            Vertex(position: [0.5, -0.5, -0.5, 1], normal: [0, 0, -1], texCoord: [1, 0]),
            Vertex(position: [0.5, 0.5, -0.5, 1], normal: [0, 0, -1], texCoord: [1, 1]),
            Vertex(position: [-0.5, 0.5, -0.5, 1], normal: [0, 0, -1], texCoord: [0, 1]),

            // Left face (x = -0.5)
            Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [-1, 0, 0], texCoord: [0, 0]),
            Vertex(position: [-0.5, 0.5, -0.5, 1], normal: [-1, 0, 0], texCoord: [1, 0]),
            Vertex(position: [-0.5, 0.5, 0.5, 1], normal: [-1, 0, 0], texCoord: [1, 1]),
            Vertex(position: [-0.5, -0.5, 0.5, 1], normal: [-1, 0, 0], texCoord: [0, 1]),

            // Right face (x = 0.5)
            Vertex(position: [0.5, -0.5, -0.5, 1], normal: [1, 0, 0], texCoord: [0, 0]),
            Vertex(position: [0.5, 0.5, -0.5, 1], normal: [1, 0, 0], texCoord: [1, 0]),
            Vertex(position: [0.5, 0.5, 0.5, 1], normal: [1, 0, 0], texCoord: [1, 1]),
            Vertex(position: [0.5, -0.5, 0.5, 1], normal: [1, 0, 0], texCoord: [0, 1]),

            // Bottom face (y = -0.5)
            Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [0, -1, 0], texCoord: [0, 0]),
            Vertex(position: [0.5, -0.5, -0.5, 1], normal: [0, -1, 0], texCoord: [1, 0]),
            Vertex(position: [0.5, -0.5, 0.5, 1], normal: [0, -1, 0], texCoord: [1, 1]),
            Vertex(position: [-0.5, -0.5, 0.5, 1], normal: [0, -1, 0], texCoord: [0, 1]),

            // Top face (y = 0.5)
            Vertex(position: [-0.5, 0.5, -0.5, 1], normal: [0, 1, 0], texCoord: [0, 0]),
            Vertex(position: [0.5, 0.5, -0.5, 1], normal: [0, 1, 0], texCoord: [1, 0]),
            Vertex(position: [0.5, 0.5, 0.5, 1], normal: [0, 1, 0], texCoord: [1, 1]),
            Vertex(position: [-0.5, 0.5, 0.5, 1], normal: [0, 1, 0], texCoord: [0, 1]),
        ]

        let indices: [UInt16] = [
            // Front face
            0, 1, 2, 0, 2, 3,
            // Back face
            4, 5, 6, 4, 6, 7,
            // Left face
            8, 9, 10, 8, 10, 11,
            // Right face
            12, 13, 14, 12, 14, 15,
            // Bottom face
            16, 17, 18, 16, 18, 19,
            // Top face
            20, 21, 22, 20, 22, 23
        ]

        return (vertices, indices)
    }
    
    private static func computeInstanceData(candles: [Candle]) -> [InstanceData] {
        let spacing: Float = 1.2
        let xStart = -Float(candles.count) * spacing / 2
        let yRange: Float = 10.0
        
        guard let pMin = candles.min(by: { $0.low < $1.low })?.low,
              let pMax = candles.max(by: { $0.high < $1.high })?.high else {
            return []
        }
        
        func normalize(_ value: Double) -> Float {
            Float((value - pMin) / (pMax - pMin)) * yRange
        }
        
        return candles.enumerated().flatMap { (i, candle) in
            let x = xStart + Float(i) * spacing
            let open = normalize(candle.open)
            let close = normalize(candle.close)
            let high = normalize(candle.high)
            let low = normalize(candle.low)
            
            let isBullish = close > open
            let (bodyTop, bodyBottom) = (max(open, close), min(open, close))
            let bodyHeight = max(bodyTop - bodyBottom, 0.1)
            
            let bodyColor: SIMD4<Float> = isBullish ? [0, 1, 0, 1] : [1, 0, 0, 1] // Green for bullish, Red for bearish
            let bodyTransform = float4x4(translation: [x, (bodyTop + bodyBottom) / 2, 0]) *
                                float4x4(scale: [0.4, bodyHeight * 5, 0.2])
            
            let upperWickTransform = float4x4(translation: [x, (bodyTop + high) / 2, 0]) *
                                     float4x4(scale: [0.1, (high - bodyTop) * 5, 0.1])
            
            let lowerWickTransform = float4x4(translation: [x, (low + bodyBottom) / 2, 0]) *
                                     float4x4(scale: [0.1, (bodyBottom - low) * 5, 0.1])
            
            return [
                InstanceData(modelMatrix: bodyTransform, color: bodyColor),
                InstanceData(modelMatrix: upperWickTransform, color: [0, 0, 0, 1]), // Black wicks
                InstanceData(modelMatrix: lowerWickTransform, color: [0, 0, 0, 1])  // Black wicks
            ]
        }
    }
}

// Matrix extensions
extension float4x4 {
    init(scale: SIMD3<Float>) {
        self.init(diagonal: [scale.x, scale.y, scale.z, 1])
    }
    
    init(translation: SIMD3<Float>) {
        self.init(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [translation.x, translation.y, translation.z, 1]
        )
    }
    
    init(rotationX angle: Float) {
        let (c, s) = (cos(angle), sin(angle))
        self.init(
            [1, 0, 0, 0],
            [0, c, s, 0],
            [0, -s, c, 0],
            [0, 0, 0, 1]
        )
    }
    
    init(rotationY angle: Float) {
        let (c, s) = (cos(angle), sin(angle))
        self.init(
            [c, 0, -s, 0],
            [0, 1, 0, 0],
            [s, 0, c, 0],
            [0, 0, 0, 1]
        )
    }
    
    init(perspectiveProjectionFov fov: Float, aspect: Float, near: Float, far: Float) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (near - far)
        self.init(
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, -1],
            [0, 0, z * near, 0]
        )
    }
}
