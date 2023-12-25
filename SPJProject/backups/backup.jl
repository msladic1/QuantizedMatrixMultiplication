include("quant_types.jl")

function calculate_shared_scale(matrix::Matrix{Float32})::Float64
    emaxelem = 127 
    shared_exp = floor(log2(maximum(abs.(matrix))))

    scale_emax = 2^(8 - 1) - 1
    shared_exp = shared_exp > scale_emax ? NaN : shared_exp
    shared_exp = shared_exp < -scale_emax ? float(-scale_emax) : shared_exp

    print("Shared exp: ")
    println(shared_exp)

    shared_exp = shared_exp - emaxelem
    
    return 2^shared_exp
end

function quantize_to_element_format(value::Float32, scale::Float64)::Int8
    if isnan(scale) || abs(value*scale) > typemax(Float32)
        return Int8(0)  # Handle special cases
    else
        Int8(round(clamp(value*scale, typemin(Int8), typemax(Int8))))
    end
end

function convert_to_quant_matrix(matrix::Matrix{Float32})#::QuantMatrix{Int8}
    shared_scale = calculate_shared_scale(matrix)
    chunks = Chunk{Int8, 16}[]
    
    for col in 1:size(matrix, 2)
        Pᵢ = Int8[]
        Vᵢ = []
        for row in 1:size(matrix, 1)
            Vi = matrix[row, col]
            pi = quantize_to_element_format(Vi, shared_scale)
            pi = Int8(pi / shared_scale)
            push!(Pᵢ, pi)
            vᵢ = isnan(shared_scale) || abs(shared_scale * pi) > typemax(Float32) ? NaN : shared_scale * pi
            push!(Vᵢ, vᵢ)
            # push!(chunks, Chunk(Int8(vᵢ), shared_scale, 0.0))  # Not sure about minimum here
        end
        println(Pᵢ)
        println(Vᵢ)
    end
    
    # return QuantMatrix(hcat([chunk for chunk in chunks]...), size(matrix))
end

