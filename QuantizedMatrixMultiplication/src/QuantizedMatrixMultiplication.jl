module QuantizedMatrixMultiplication

include("multiplication.jl")

export calculate_shared_scale
export quantize_to_element_format
export convert_to_quant_matrix
export pack
export *
export QuantMatrix
export Chunk

using Random

end