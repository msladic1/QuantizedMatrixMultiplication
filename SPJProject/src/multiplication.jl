include("quant_types.jl")
include("quant_functions.jl")

function mul(Q::QuantMatrix{UInt16}, A::Matrix{T}, BLOCKSIZE=32) where T
    NBLOCKS = size(A, 1) ÷ BLOCKSIZE
    C = zeros(Float32, size(A, 2) , size(A, 2))
    for i ∈ axes(Q, 1)
        for j ∈ axes(A, 2)
            Cx = zero(eltype(C))
            for k ∈ axes(Q, 2)
                shared_scale = Q.matrix[i, k].scale
                v1 = isnan(shared_scale) || abs(shared_scale * pi) > typemax(Float32) ? NaN : clamp((Q.matrix[i, k].values >> 8 / 2^6), typemin(Int8), typemax(Int8)) * Float32(shared_scale)
                v2 = isnan(shared_scale) || abs(shared_scale * pi) > typemax(Float32) ? NaN : clamp((Q.matrix[i, k].values & 0xFF / 2^6), typemin(Int8), typemax(Int8)) * Float32(shared_scale)
                
                Cx += v1 * A[origin_col_idx(k, i, NBLOCKS, BLOCKSIZE), j] * Q.matrix[i, k].signs[1] 
                Cx += v2 * A[origin_col_idx(k, i, NBLOCKS, BLOCKSIZE)+Int(BLOCKSIZE/2), j] * Q.matrix[i, k].signs[2] 
            end

            C[origin_row_idx(i, NBLOCKS), j] += Cx
        end
    end
    return C
end
