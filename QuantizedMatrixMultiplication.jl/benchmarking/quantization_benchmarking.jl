include("../src/quant_types.jl")
include("../src/quant_functions.jl")

using Random
using BenchmarkTools
using Profile

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

weights = initialize_weights(64, 128)

quant_matrix, scales = convert_to_quant_matrix(weights)

# Check for wanrtypes first
@code_warntype convert_to_quant_matrix(weights)
@code_warntype pack(quant_matrix, scales, 32)

# Calculate times
@benchmark convert_to_quant_matrix(weights)
@benchmark pack(quant_matrix, scales, 32)

# Profiling
Profile.init()
Profile.clear()
@profile convert_to_quant_matrix(weights)
Profile.print()

function run_convert(weights, n)
    for _ in 1:n
        convert_to_quant_matrix(weights)
    end
end

@profview run_convert(weights,Int(1e5))

Profile.clear()
@profile pack(quant_matrix, scales, 32)
Profile.print()

function run_pack(quant_matrix, scales, n)
    for _ in 1:n
        pack(quant_matrix, scales, 32)
    end
end

@profview run_pack(quant_matrix, scales, Int(1e5))
