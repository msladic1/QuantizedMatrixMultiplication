include("../src/quant_types.jl")
include("../src/quant_functions.jl")
include("../src/multiplication.jl")

using Random
using BenchmarkTools
using Profile

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

mat2_size = (128, 64)
m = initialize_weights(64, 128)
v = rand(0:20, mat2_size) .|> Float32
# v = initialize_weights(128, 64)

quant_matrix, scales = convert_to_quant_matrix(m) 

qm = pack(quant_matrix, scales, 32)

reg = m * v # regular multiplication
my = qm * v # my multiplication

@code_warntype qm * v

@benchmark qm * v
@benchmark m * v

function run_multi(a, b, n)
    for _ in 1:n
        a * b
    end
end

@profview run_multi(qm, v, Int(1e3))

sum(m*v)
sum(qm*v)