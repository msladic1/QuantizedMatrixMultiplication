include("quant_types.jl")
include("quant_functions.jl")

function Base.:*(Q::QuantMatrix{UInt16, Float32}, A::Matrix{T}) where T
    BLOCKSIZE = Q.blocksize
    BLOCKSIZE2 = Int(BLOCKSIZE/2)
    NBLOCKS = size(A, 1) ÷ BLOCKSIZE
    C = zeros(Float32, size(A, 2) , size(A, 2))

    axes_q2 = axes(Q, 2)
    axes_a2 = axes(A, 2)
    @inbounds for i ∈ axes(Q, 1)
        for j ∈ axes_a2
            Cx = zero(eltype(C))
            or = origin_row_idx(i, NBLOCKS)
            shared_scale = Q.matrix[i, 1].scale

            for k ∈ axes_q2
                v = Q.matrix[i, k].values
                row = Q.matrix[i, k]
                oi = origin_col_idx(k, i, NBLOCKS, BLOCKSIZE)
                Cx += (v >> 8) * A[oi, j] * row.signs[1]
                Cx += (v & 0xFF) * A[oi + BLOCKSIZE2, j] * row.signs[2]
            end

            C[or, j] += Cx / 2^6 * shared_scale
        end
    end

    return C
end
