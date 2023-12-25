# Types Definition

struct Chunk{T,N}
    values::Vector{T}
    scale::Float64
    minimum::Float64
end

struct QuantMatrix{T} <: AbstractMatrix{T}
    matrix::Matrix{Chunk{T}}
    dim::Tuple{Int, Int}
end
