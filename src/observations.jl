using POMDPs
using POMDPModelTools

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
function POMDPs.observation(pomdp::ConnectPOMDP, a::Tuple, s::Deterministic)
    # Total Number of Decision-Raking Robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    # a_ind = POMDPs.actionindex(pomdp, a)

    # 𝒮 = POMDPs.states(pomdp)

    #𝒪 = []
    #for k = 1:num_bots
    #    push!(𝒪, compute_observations(pomdp, num_bots, a_ind, s, 𝒮[1]))
    #end

    return compute_observations(pomdp, num_bots, s.val)
end

function POMDPs.observation(pomdp::ConnectPOMDP, a::Tuple, s::Tuple)
    return POMDPs.observation(pomdp, a, Deterministic(s))
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
    s::Tuple,
)
    p_bins = zeros(9, num_bots)
    s_reach = []
    for k = 1:num_bots
        # find the order of likeliest states using the given action
        sp_order = [pomdp.sp_order_table[:, 9]...]

        # reset the bin distributions
        p_bins[:, k] = [pomdp.p_bins_observation...]
        
        p_bins[2:9, k] = (1-p_bins[1, k])/8 .* ones(8)

        # sort the probability bins to the order of possible states
        p_bins[:,k] = p_bins[sortperm(sp_order), k]

        # compute reachable states and check out-of-bounds constraint
        p_bins[:,k], s_reach_k = compute_p_reachable(pomdp, p_bins[:,k], s[k])

        push!(s_reach, s_reach_k)

        if abs(sum(p_bins[:,k]) - 1) > 1e-4
            @warn("Discrete Gaussian bins do not sum to 1 ($(sum(p_bins[:,k]))) -- see observations.jl")
        end
    end
    
    p_s_iter = zip(Base.product(s_reach...), Base.product([p_bins[:,k] for k in 1:num_bots]...))
    #s_prod = Base.product(s_reach...)
    #p_iter = Base.product([p_bins[:,k] for k in 1:num_bots]...)

    p_joint = Float64[]
    p_state = []
    for (s, p) in p_s_iter
        p_joint_i = prod(p)
        if p_joint_i > eps()
            push!(p_joint,prod(p))
            push!(p_state, s)
        end
    end

    return POMDPModelTools.SparseCat(p_state, p_joint)
end