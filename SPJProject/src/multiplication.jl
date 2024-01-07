include("quant_types.jl")
include("quant_functions.jl")

using LoopVectorization

function Base.:*(Q::QuantMatrix{UInt16}, A::Matrix{T}) where T
    BLOCKSIZE = Q.blocksize
    NBLOCKS = size(A, 1) ÷ BLOCKSIZE
    C = zeros(Float32, size(A, 2) , size(A, 2))

    for i ∈ axes(Q, 1)
        for j ∈ axes(A, 2)
            Cx = zero(eltype(C))

            shared_scale = Q.matrix[i, 1].scale

            for k ∈ axes(Q, 2)
                Cx += Float32(Q.matrix[i, k].values >> 8) * A[origin_col_idx(k, i, NBLOCKS, BLOCKSIZE), j] * Float32(Q.matrix[i, k].signs[1]) 
                Cx += Float32(Q.matrix[i, k].values & 0xFF) * A[origin_col_idx(k, i, NBLOCKS, BLOCKSIZE)+Int(BLOCKSIZE/2), j] * Float32(Q.matrix[i, k].signs[2])
            end

            C[origin_row_idx(i, NBLOCKS), j] += clamp(Float32(Cx / 2^6), typemin(Int8), typemax(Int8)) * Float32(shared_scale)
        end
    end

    return C
end
