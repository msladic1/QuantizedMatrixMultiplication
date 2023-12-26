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
    @test isapprox(d, weights, atol=1e-3, rtol=1e-3) == 1
    @test isapprox(d2, weights2, atol=1e-2, rtol=1e-2) == 1
end

@testset "Check if quantized values are in valid range" begin
    q, d = convert_to_quant_matrix(weights)
    weights2 = initialize_weights(100, 100)
    q2, d2 = convert_to_quant_matrix(weights2)
    @test maximum(q) <= 127 && minimum(q) >= -127
    @test maximum(q2) <= 127 && minimum(q2) >= -127
end