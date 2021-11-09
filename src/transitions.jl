using POMDPs

include("./params.jl")
include("./actions.jl")
include("./states.jl")

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
     |        s' = (i-1, j+1) or s' = (i-1, j-1) or
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

If a potential state is out of bounds, the transition probability will be set 
to 0 and its probability will be added to the probability of staying at the current
state.

The leader robots are assigned probabilty = 1.0 to transiton to their desired 
state.

Sample from the resulting transition distribution using rand(T[i], n) where
i indicates the ith robots distribution and n is the number of samples

Inputs:
    pomdp   The ConnectPOMDP instance
    s       Array of agent states
    a       Array of agent actions

Outputs:
    T       Array of DiscreteUnivariateDistributions describing the probability
            of transitioning to each of the states adjacent to state s
"""
function POMDPs.transition(pomdp::ConnectPOMDP, s::Tuple, a::Tuple) 
    # Total Number of Decision-Raking Robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    a_ind = POMDPs.actionindex(pomdp, a)

    𝒮 = CartesianIndices(ones(pomdp.n_grid_size, pomdp.n_grid_size))

    T = []
    for k = 1:num_bots
        # find the order of likeliest states using the given action
        sp_order = [pomdp.sp_order_table[:, a_ind[k]]...]

        # reset the bin distributions
        if k > pomdp.num_leaders
            p_bins = [pomdp.p_bins_follower...]
        else
            p_bins = [pomdp.p_bins_leader...]
        end
        
        if a_ind[k] == 9
            # if action == :stay, assign the highest bin to the current state
            # and uniformly distribution the remaining probability among the others
            p_bins[2:9] = (1-p_bins[1])/8 .* ones(8)
        end

        # sort the probability bins to the order of possible states
        p_bins = p_bins[sortperm(sp_order)]

        # compute reachable states and check out-of-bounds constraint
        compute_p_reachable!(p_bins, s[k], 𝒮)

        if abs(sum(p_bins) - 1) > 1e-4
            @warn("Discrete Gaussian bins do not sum to 1 -- see transitions.jl")
        end

        if k > pomdp.num_leaders
            # add categorical distribution to transition function array
            push!(T, Categorical(p_bins))
        else
            # assign probability of 1 to desired state for leaders
            push!(T, Categorical(p_bins))
        end
    end

    return T
end

"""

Compute the CartesianIndex for states adjacent to input state s
    
input
    s           single state to compute reachable states about

output
    s_reach     array of states corresponding to the transition probability ordering
"""
function compute_reachable_states(s::CartesianIndex)

    s_reach = [s for k in 1:9]
    s_reach[1] += CartesianIndex( 1,  0) # :east
    s_reach[2] += CartesianIndex( 1,  1) # :northeast
    s_reach[3] += CartesianIndex( 0,  1) # :north
    s_reach[4] += CartesianIndex(-1,  1) # :northwest
    s_reach[5] += CartesianIndex(-1,  0) # :west
    s_reach[6] += CartesianIndex(-1, -1) # :southwest
    s_reach[7] += CartesianIndex( 0, -1) # :south
    s_reach[8] += CartesianIndex( 1, -1) # :southeast
  # s_reach[9] += CartesianIndex( 0,  0) # :stay

    return s_reach
end

"""
Adjust the probability distribution over the reachable states.
Set the probability of an unreachable state to 0 and add it to the probability
of staying at the same state.

input
    p_bins  Array of probabilities sorted from largest-to-smallest representing
            the discrete distribution over adjacent states

    s       Single state to compute reachable states about

"""
function compute_p_reachable!(
    p_bins::Array{Float64}, 
    s::CartesianIndex, 
    𝒮::CartesianIndices{2,Tuple{Base.OneTo{Int64},Base.OneTo{Int64}}}
)
    reachable_states = compute_reachable_states(s)
    for i = 1:length(reachable_states)
        # Check each reachable state for out of bounds constraint
        if reachable_states[i] ∉ 𝒮
            # add the probability of the out-of-bounds state to the stationary transition
            p_bins[9] += p_bins[i]
            p_bins[i] = 0
        end
    end
    return p_bins
end
