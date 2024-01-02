include("quant_types.jl")

function calculate_shared_scale(row::AbstractArray{Float32})::Float64
    emaxelem = 127 
    shared_exp = floor(log2(maximum(abs.(row))))

    scale_emax = 2^(8 - 1) - 1
    shared_exp = shared_exp > scale_emax ? NaN : shared_exp
    shared_exp = shared_exp < -scale_emax ? float(-scale_emax) : shared_exp

    emax = emaxelem^floor(log2(maximum(abs.(row))))

    # shared_exp = shared_exp - emax
    
    return 2^shared_exp
end

function quantize_to_element_format(values::Vector{Float32}, scale::Float64)::Vector{Int8}
    result = Int8[]

    for value in values
        scaled_value = Float32(value / scale)
        if isnan(scale) || abs(scaled_value * 2^6) > typemax(Float32)
            push!(result, Int8(0))  # Handle special cases
        else
            push!(result, clamp(round(scaled_value * 2^6), typemin(Int8), typemax(Int8)))
        end
    end
    
    return result
end

function convert_to_quant_matrix(matrix::Matrix{Float32})
    quantized = zeros(Int, size(matrix, 1), size(matrix, 2))
    scales = zeros(Float64, size(matrix, 1))

    for row in 1:size(matrix, 1)

        shared_scale = calculate_shared_scale(matrix[row, :])
        scales[row] = shared_scale

        Pᵢ = quantize_to_element_format(matrix[row, :], shared_scale)

        quantized[row, :] = Pᵢ
    end

    return quantized, scales
end

function pack(a::Int, b::Int)
    return UInt16((a << 8) + b)
end

origin_col_idx(j, i, NBLOCKS, BLOCKSIZE=32) = (mod1(i, NBLOCKS) - 1) * BLOCKSIZE + j
origin_row_idx(i, NBLOCKS) = fld1(i, NBLOCKS)

function pack(m::Matrix{Int64}, scales::Vector{Float64}, BLOCKSIZE=32)
    mat_size = size(m)

    HALFBLOCK = BLOCKSIZE ÷ 2 
    NCOLS = mat_size[2]
    NBLOCKS = NCOLS ÷ BLOCKSIZE # TODO: Round it to higher number and pad extra spaces with 0x0000

    dimension = Pair(NBLOCKS * mat_size[1], BLOCKSIZE ÷ 2)

    qm = Matrix{Chunk{UInt16}}(undef, NBLOCKS * mat_size[1], BLOCKSIZE ÷ 2)

    for i in axes(qm, 1)
            row_idx = origin_row_idx(i, NBLOCKS)
        for j in axes(qm, 2)
            col_idx = origin_col_idx(j, i, NBLOCKS, BLOCKSIZE)

            first_sgn = 1
            second_sgn = 1
            first_val = m[row_idx, col_idx]
            second_val = m[row_idx, col_idx+HALFBLOCK]

            ########### Refactor this part ###########
            if m[row_idx, col_idx] < 0
                first_val *= -1
                first_sgn = -1
            end
            if m[row_idx, col_idx+HALFBLOCK] < 0
                second_val *= -1
                second_sgn = -1
            end
            ##########################################

            chunk = Chunk{UInt16}(pack(first_val, second_val), scales[row_idx], Pair(first_sgn, second_sgn))  

            qm[i, j] = chunk
        end
    end

    fully_quantized_matrix = QuantMatrix{UInt16}(qm, dimension, BLOCKSIZE)

    return fully_quantized_matrix
end
