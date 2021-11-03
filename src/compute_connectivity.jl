# The following function takes the current state as an input
# and returns the algebraic connectivity of the multi-robot system.

using Distributions
using LinearAlgebra

function compute_connectivity(s_tot::Array, pomdp::ConnectPOMDP)
    n = length(stot)
    
    adjacency_matrix = zeros((n,n))
    degree_matrix = zeros((n,n))

    trunc_Normal = TruncatedNormal(0, pomdp.σ_transition, -pomdp.connect_thresh, -pomdp.connect_thresh)

    for i in 1:n
        for j in 1:n
            dist = sqrt((s_tot[i][1]-s_tot[j][1])^2+(s_tot[i][2]-s_tot[j][2])^2)
            adjacency_matrix[i,j] = pdf(trunc_Normal, dist)
        end

        degree_matrix[i,i] = sum(adjacency_matrix[i,:])

    end

    return sort(eigvals(degree_matrix))[2]

end