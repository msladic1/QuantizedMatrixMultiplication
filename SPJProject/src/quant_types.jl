# Types Definition

struct Chunk{T,N}
    values::T
    scale::Float64
    signs::Pair{Int, Int}
end

struct QuantMatrix{T} <: AbstractMatrix{T}
    matrix::Matrix{Chunk{T}}
    dim::Pair{Int, Int}
end
