# Types Definition

struct Chunk{T}
    values::T
    scale::Float64 # F generalize it
    signs::Pair{Int, Int} # Store as one byte
end

struct QuantMatrix{T} <: AbstractMatrix{T}
    matrix::Matrix{Chunk{T}}
    dim::Pair{Int, Int}
    blocksize::Int
end

function Base.display(chunk::Chunk{T}) where T
    println(chunk.values)
    println(chunk.scale)
    println(chunk.signs)
end

function Base.display(qm::QuantMatrix{T}) where T
    for i in 1:5
        for j in 1:Int(qm.blocksize/2)
            hex_str = string(qm.matrix[i, j].values, base=16)
            print("0x$(lpad(hex_str, 4, '0'))")
            print("\t")
        end
        println()
    end
end

Base.size(qm::QuantMatrix) = qm.dim

function Base.getindex(qm::QuantMatrix{T}, i, j) where T
    return qm.matrix[i, j]
end
