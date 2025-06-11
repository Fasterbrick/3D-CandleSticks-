//Shaders.metal
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 texCoord [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 viewNormal [[flat]];
    float2 texCoord;
};

struct InstanceData {
    float4x4 modelMatrix;
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant float4x4 &viewMatrix [[buffer(1)]],
                             constant float4x4 &projectionMatrix [[buffer(2)]],
                             constant InstanceData *instances [[buffer(3)]],
                             uint instance_id [[instance_id]]) {
    VertexOut out;
    float4x4 modelMatrix = instances[instance_id].modelMatrix;
    float4 color = instances[instance_id].color;
    float4 worldPosition = modelMatrix * in.position;
    float4 viewPosition = viewMatrix * worldPosition;

    float3 viewNormal = normalize((viewMatrix * modelMatrix * float4(in.normal, 0)).xyz);

//    // Extract scale factors (for reference)
//    float xScale = modelMatrix[0][0]; // Width (X-axis)
//    float yScale = modelMatrix[1][1]; // Height (Y-axis)
//    float zScale = modelMatrix[2][2]; // Depth (Z-axis)

    // Use world position to compute texture coordinates, tiled by a density factor
    float tilingDensity = 1; // Adjust this: higher = more repeats, lower = fewer repeats
    float2 adjustedTexCoord = in.texCoord; // Default to original texCoord as fallback

    if (abs(in.normal.z) > 0.5) { // Front/back faces (Z-normal)
        // Map X (width) and Y (height) from world position
        adjustedTexCoord = float2(worldPosition.x, worldPosition.y) * tilingDensity;
    } else if (abs(in.normal.x) > 0.5) { // Left/right faces (X-normal)
        // Map Z (depth) to texture X, Y (height) to texture Y
        adjustedTexCoord = float2(worldPosition.z, worldPosition.y) * tilingDensity;
    } else if (abs(in.normal.y) > 0.5) { // Top/bottom faces (Y-normal)
        // Map X (width) to texture X, Z (depth) to texture Y
        adjustedTexCoord = float2(worldPosition.x, worldPosition.z) * tilingDensity;
    }

    out.position = projectionMatrix * viewPosition;
    out.color = color;
    out.viewNormal = viewNormal;
    out.texCoord = adjustedTexCoord;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant float3 &lightDirection [[buffer(0)]],
                              texture2d<float> stoneTexture [[texture(0)]],
                              sampler textureSampler [[sampler(0)]]) {
    float2 texCoord = in.texCoord;
    float4 textureColor = stoneTexture.sample(textureSampler, texCoord);

    float diffuse = max(dot(normalize(in.viewNormal), -lightDirection), 0.0);
    float ambient = 0.5;
    float4 color = textureColor * (ambient + diffuse);
    color = mix(color, in.color, 0.5);
    return color;
}
