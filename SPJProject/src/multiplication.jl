include("quant_types.jl")
include("quant_functions.jl")

function Base.:*(Q::QuantMatrix{Int8, Float32}, A::Matrix{T}) where T
    C = zeros(Float32, Q.dim[1] , size(A, 2))

    axes_q2 = axes(Q, 2)
    axes_a2 = axes(A, 2)

    @inbounds for i ∈ axes(Q, 1)
        for j ∈ axes_a2
            Cx = zero(eltype(C))

            shared_scale = Q.matrix[i, 1].scale
            
            index = 1

            for k ∈ axes_q2
                v = Q.matrix[i, k].values
                chunk = Q.matrix[i, k]

                Cx += v[1] * A[index, j]; index += 1    
                Cx += v[2] * A[index, j]; index += 1
                Cx += v[3] * A[index, j]; index += 1
                Cx += v[4] * A[index, j]; index += 1
            end

            C[i, j] += Cx / 2^6 * shared_scale
        end
    end

    return C
end
