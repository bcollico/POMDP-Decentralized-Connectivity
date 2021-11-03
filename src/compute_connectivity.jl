using Distributions
using LinearAlgebra

"""
    The following function takes the current state of the system as an input 
    and returns the algebraic connectivity.

    It constructs the adjacency_matrix by adding to element (i,j) the connectivity
    between agents i and j. The connectivity is assumed non-binary, but spanning the range 
    (0,1). In order to do so, the distance between agents i and j is fed to a truncated gaussian
    (initialized by the corresponding parameters in the ConnectPOMDP structure).

    The degree_matrix is also determined and the laplacian_matrix = adjacency_matrix - degree_matrix 
    is finally used to get the algebraic connectivity (its second smallest eigenvalue).
"""
function compute_connectivity(s_tot::Array, pomdp::ConnectPOMDP)

    # number of agents
    n = pomdp.num_agents + pomdp.num_leaders
    
    adjacency_matrix = zeros((n,n))
    degree_matrix = zeros((n,n))
    laplacian_matrix = zeros((n,n))

    # initialize truncated normal distribution
    trunc_Normal = TruncatedNormal(0, pomdp.σ_transition, -pomdp.connect_thresh, pomdp.connect_thresh)

    for i in 1:n
        for j in 1:n
            dist = sqrt((s_tot[i][1]-s_tot[j][1])^2+(s_tot[i][2]-s_tot[j][2])^2)

            # update adjacency_matrix
            if j==i
                adjacency_matrix[i,j] = dist
            else
                adjacency_matrix[i,j] = pdf(trunc_Normal, dist)
            end
        end

        # determine degree_matrix
        degree_matrix[i,i] = sum(adjacency_matrix[i,:])

    end

    # determine laplacian_matrix
    laplacian_matrix = degree_matrix - adjacency_matrix

    # return second smallest eigenvalue
    return sort(eigvals(laplacian_matrix))[2]

end
