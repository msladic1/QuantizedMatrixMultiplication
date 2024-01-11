module SPJProject

include("quant_types.jl")
include("quant_functions.jl")
include("multiplication.jl")

export convert_to_quant_matrix

using Random

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

# Initialize a 3x3 matrix of weights with a small random normal distribution
weights = initialize_weights(6, 12)

# Quantize matrix values
quant_matrix, scales = convert_to_quant_matrix(weights) 
# print(isapprox(dequant_matrix, weights, atol=1e-1, rtol=1e-1))

quant_matrix
scales

# Get QuantMatrix
qm = pack(quant_matrix, scales, 6)

mat2_size = (12, 6)
v = rand(0:20, mat2_size) .|> Float32

qm * v
weights * v

qm.matrix[1,1].signs[2]
qm.blocksize

mat2_size = (128, 64)
m = initialize_weights(64, 128)
v = rand(0:20, mat2_size) .|> Float32
v = initialize_weights(128, 64)

quant_matrix, scales = convert_to_quant_matrix(m) 

m
quant_matrix
v
scales

qm = pack(quant_matrix, scales, 16)

qm
reg = m * v # regular multiplication
my = qm * v # my multiplication

sum(m*v)
sum(qm*v)
end