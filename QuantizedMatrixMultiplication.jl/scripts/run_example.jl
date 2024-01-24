using QuantizedMatrixMultiplication

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

# Initialize a 3x3 matrix of weights with a small random normal distribution
weights = initialize_weights(6, 15)
sizeof(weights)
# Quantize matrix values
quant_matrix, scales = convert_to_quant_matrix(weights) 
sizeof(quant_matrix)
# print(isapprox(dequant_matrix, weights, atol=1e-1, rtol=1e-1))

quant_matrix
scales

# Get QuantMatrix
qm = pack(quant_matrix, scales)
size(qm)
sizeof(qm)
typeof(qm)

mat2_size = (15, 8)
v = rand(0:20, mat2_size) .|> Float32

qm * v
weights * v

mat2_size = (128, 64)
m = initialize_weights(64, 128)
v = rand(0:20, mat2_size) .|> Float32

quant_matrix, scales = convert_to_quant_matrix(m) 

m
quant_matrix
v
scales

qm = pack(quant_matrix, scales)

reg = m * v # regular multiplication
my = qm * v # my multiplication
