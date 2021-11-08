using POMDPs

include("./params.jl")
include("./states.jl")
include("./transitions.jl")


"""Return the full observation space -- 𝒪 == 𝒮"""
function POMDPs.observations(pomdp::ConnectPOMDP)
    return POMDPs.states(pomdp)
end

"""
Return the discrete gaussian distribution of observations of each robot for each
robot -- each robot has num_robots observation vectors consisting of a probability
distribution over each robots neighborhood of states

input
    pomdp   The ConnectPOMDP struct
    
    a       Array of action symbols

    s       Array of cartesian index states

output
    𝒪       Array of vectors of observation distributions
"""
function POMDPs.observation(pomdp::ConnectPOMDP, a::Array{Symbol}, s::Array{CartesianIndex{2},1})
    # Total Number of Decision-Raking Robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    a_ind = POMDPs.actionindex(pomdp, a)

    𝒮 = POMDPs.states(pomdp)

    𝒪 = []
    for k = 1:num_bots
        push!(𝒪, compute_observations(pomdp, num_bots, a_ind, s, 𝒮[1]))
    end

    return 𝒪
end

"""
Compute the vector of observation distributions for a single robot

input
    pomdp   The ConnectPOMDP struct
    
    num_bots   Total number of robots
    
    a_ind   Array of action indices

    s       Array of cartesian index states

    𝒮       Full state space

output
    𝒪       Vector of observations for a single robot
"""
function compute_observations(
    pomdp::ConnectPOMDP,
    num_bots::Int,
    a_ind::Array{Int},
    s::Array{CartesianIndex{2},1},
    𝒮::CartesianIndices{2,Tuple{Base.OneTo{Int64},Base.OneTo{Int64}}}
)
    𝒪 = []
    for k = 1:num_bots
        # find the order of likeliest states using the given action
        sp_order = [pomdp.sp_order_table[:, 9]...]

        # reset the bin distributions
        p_bins = [pomdp.p_bins_observation...]
        
        p_bins[2:9] = (1-p_bins[1])/8 .* ones(8)

        # sort the probability bins to the order of possible states
        p_bins = p_bins[sortperm(sp_order)]

        # compute reachable states and check out-of-bounds constraint
        compute_p_reachable!(p_bins, s[k], 𝒮)

        if abs(sum(p_bins) - 1) > 1e-4
            @warn("Discrete Gaussian bins do not sum to 1 -- see transitions.jl")
        end

        # add categorical distribution to transition function array
        push!(𝒪, Categorical(p_bins))
    end
    
    return 𝒪
end
