# Types Definition

struct Chunk{T, F}
    values::T
    scale::F # F generalize it
    signs::Pair{Int8, Int8} # Store as one byte
end

struct QuantMatrix{T, F} <: AbstractMatrix{T}
    matrix::Matrix{Chunk{T,F}}
    dim::Pair{Int, Int}
    blocksize::Int8
end

function Base.display(chunk::Chunk{T, F}) where T where F
    println(chunk.values)
    println(chunk.scale)
    println(chunk.signs)
end

function Base.display(qm::QuantMatrix{T,F}) where T where F
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

function Base.getindex(qm::QuantMatrix{T,F}, i, j) where T where F
    return qm.matrix[i, j]
end
