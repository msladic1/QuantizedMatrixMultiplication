# Types Definition

struct Chunk{T, F}
    values::Tuple{T,T,T,T}  
    scale::F 
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
    for i in 1:min(qm.dim[1], 10)
        for j in 1:min(qm.dim[2], 10)
            print(qm.matrix[i,j].values)
            print("\t")
        end
        println()
    end
end

Base.size(qm::QuantMatrix) = qm.dim[1], qm.dim[2] 

function Base.getindex(qm::QuantMatrix{T,F}, i, j) where T where F
    return qm.matrix[i, j]
end
