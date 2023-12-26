module SPJProject  

include("quant_types.jl")
include("quant_functions.jl")

export convert_to_quant_matrix

using Random

function initialize_weights(rows, cols, scale=Float32(0.01))
    return scale * randn(Float32, rows, cols)
end

# Initialize a 3x3 matrix of weights with a small random normal distribution
weights = initialize_weights(4069, 11008)

# Convert matrix to QuantMatrix
quant_matrix, dequant_matrix = convert_to_quant_matrix(weights) 
print(isapprox(dequant_matrix, weights, atol=1e-1, rtol=1e-1))

# Display the original and quantized matrices
# println("Original Matrix:")
# println(example_matrix)
# println("\nQuantized Matrix:")
# println(quant_matrix.matrix)
end