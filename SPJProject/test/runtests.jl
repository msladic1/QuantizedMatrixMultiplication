using SPJProject
using Test
using Random

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

weights = initialize_weights(5, 5)

@testset "Check if dequantized matrix is close enough to the original" begin
    q, d = convert_to_quant_matrix(weights)
    weights2 = initialize_weights(100, 100)
    q2, d2 = convert_to_quant_matrix(weights2)
    @test isapprox(clamp((q[1, 1] / 2^6), typemin(Int8), typemax(Int8)) * d[1], weights[1, 1], atol=1e-3, rtol=1e-3) == 1
    @test isapprox(clamp((q2[31, 52] / 2^6), typemin(Int8), typemax(Int8)) * d2[31], weights2[31, 52], atol=1e-2, rtol=1e-2) == 1
    for i ∈ axes(q2, 1)
        for j ∈ axes(q2, 2)
            @test q2[i, j] / 2^6 * d2[i] - weights2[i, j] <= 0.001
        end
    end
end

@testset "Check if quantized values are in valid range" begin
    q, d = convert_to_quant_matrix(weights) 
    weights2 = initialize_weights(100, 100)
    q2, d2 = convert_to_quant_matrix(weights2)
    @test maximum(q) <= 127 && minimum(q) >= -128
    @test maximum(q2) <= 127 && minimum(q2) >= -128
end

@testset "Test Pack function" begin
    weights2 = initialize_weights(64, 128)
    q, d = convert_to_quant_matrix(weights2)
    BLOCKSIZE = 32
    packed = pack(q, d, BLOCKSIZE)
    @test typeof(packed) == QuantMatrix{UInt16, Float32}
    @test packed.dim[1] == Int(64*128/BLOCKSIZE) && packed.dim[2] == Int(BLOCKSIZE/2)
    @test typeof(packed.matrix[1]) == Chunk{UInt16, Float32}
    @test (packed.matrix[1, 1].values >> 8) * packed.matrix[1, 1].signs[1] == q[1, 1]
    @test (packed.matrix[1, 1].values & 0xFF) * packed.matrix[1, 1].signs[2] == q[1, 17]
end

@testset "Multiplication tests" begin
    weights = initialize_weights(12, 24)
    q, d = convert_to_quant_matrix(weights)
    BLOCKSIZE = 6
    mat2_size = (24, 12)
    v = rand(0:20, mat2_size) .|> Float32
    packed = pack(q, d, BLOCKSIZE)
    product = packed * v
    real = weights * v
    @test size(product, 1) == 12 && size(product, 2) == 12
    @test sum(real) - sum(product) <= 0.2
    @test product[2, 4] - real[2, 4] <= 0.01
    for i ∈ axes(product, 1)
        for j ∈ axes(product, 2)
            @test product[i, j] - real[i, j] <= 0.01
        end
    end
end