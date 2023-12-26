using SPJProject
using Test
using Random

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

weights = initialize_weights(5, 5)

@testset "Check if dequantized matrix is close enough to the original" begin
    q, d = convert_to_quant_matrix(weights)
    @test isapprox(d, weights, atol=1e-3, rtol=1e-3) == 1
end