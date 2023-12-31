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
end

@testset "Check if quantized values are in valid range" begin
    q, d = convert_to_quant_matrix(weights)
    weights2 = initialize_weights(100, 100)
    q2, d2 = convert_to_quant_matrix(weights2)
    @test maximum(q) <= 127 && minimum(q) >= -127
    @test maximum(q2) <= 127 && minimum(q2) >= -127
end