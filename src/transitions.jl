using POMDPs

include("./params.jl")
include("./actions.jl")

"""

Due to motion uncertainties, there exists a probability that the agent does not
arrive at the intended state as dictated by it's chosen action. The state 
transition function, therefore, is a probability distribution over the agent's 
adjacent states to determine the state transtion given an action.

The transition function is a discrete gaussian distribution with specified 
bin width and standard deviation -- the mean of the distribution is assigned to
the intended state. An example is shown with the state transitions listed in 
ordering of most likely to least likely:

                 ---     a = :east    ---
                | s |    ------->    | s'|
                 ---                  ---
              s = (i, j)         s' ~ T(s'|s, a)

Most Likely:  s' = (i+1, j  )
     |        s' = (i+1, j+1) or s' = (i+1, j-1)
     |        s' = (i  , j+1) or s' = (i  , j-1)
     |      s' = (i-1, j+1) or s' = (i-1, j-1) or
Least Likely: s' = (i-1, j  ) or s' = (i  , j  )

The categorical distribution over the candidate transition states is organized 
using the action index convention, such that the i-th category in the 
distribution corresponds to the following mapping:

                 4      3      2
                    ---------
                   |         |
                 5 |    9    | 1
                   |         |
                    ---------
                 6      7      8

Inputs:
    pomdp   The ConnectPOMDP instance
    s       Array of agent states
    a       Array of agent actions

Outputs:
    𝖳       Array of DiscreteUnivariateDistributions describing the probability
            of transitioning to each of the states adjacent to state s
"""
function POMDPs.transition(pomdp::ConnectPOMDP, s::Array{CartesianIndex{2},1}, a::Array{Symbol}) 

    # The Grid Size (i.e., n_grid_size x n_grid_size)
    n_grid_size = pomdp.n_grid_size

    # Total Number of Decision-Raking Robots
    num_agents = pomdp.num_agents

    a_ind = POMDPs.actionindex(pomdp::ConnectPOMDP, a::Array{Symbol})
    p_bins = pomdp.p_transition_bins

    if abs(sum(p_bins) - 1) > 1e-4
        warn("Discrete Gaussian bins do not sum to 1 -- see transitions.jl")
    end

    T = []
    for k = 1:num_agents
        # find the order of likeliest states using the given action
        sp_order = a_ind[k] .+ [0, 1, -1, 2, -2, 3, -3, -4]
        sp_order[sp_order .<= 0] .+= 8
        sp_order[sp_order .>= 9] .-= 8
        push!(sp_order, 9)

        # add categorical distribution to transition function array
        push!(T, Categorical(p_bins[sortperm(sp_order)]))
    end

    return T
end