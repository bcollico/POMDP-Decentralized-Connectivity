using POMDPs
using Distributions
using LinearAlgebra

mutable struct ParamsStruct
    # Problem Setup
    num_agents::Int
    num_leaders::Int
    horizon::Int 

    # Map Parameters
    n_grid_size::Int
    grid_dimension::Int
    n_obstacles::Int

    # Rewards
    R_o::Int    # Negative reward for agent-obstacle collision
    R_a::Int    # Negative reward for agent-agent    collision
    R_λ::Int    # Negative reward for loss of connectivity

    # Sensing Uncertainty
    σ_obs::Float64    # Standard deviation of Gaussian measurement noise
    b_obs::Float64    # Bin width of discrete Gaussian model

    # Connectivity Probability Distribution (Truncated Gaussian)
    σ_connect::Float64  # Standard deviation;
    connect_thresh::Int # Maximum distance threshold for connectivity

    # Transition probability distribution (Discrete Gaussian)
    σ_transition::Float64 # Standard deviation of Gaussian process noise
    b_transition::Float64 # Bin width of discrete Gaussian model

    # Collision Buffer Distance (L-nfty Norm)
    object_collision_buffer::Int 
    agent_collision_buffer::Int

    # Learning Parameters
    γ::Float64  # Discount Factor, in range(0, 1)
    α::Float64  # Learning Factor, in range(0, 1)

    """Default constructor for ParamsStruct"""
    function ParamsStruct()
        return new(1, 1, 10,        # Problem Setup
                  10, 2, 5,         # Map Parameters
                 -1e4, -1e4, -1e3,  # Rewards
                  1e-10, 1.0,       # Sensing Uncertainty
                  1.0, 2,           # Connectivity Probability Distribution
                  1.0, 1.0,         # Transition probability distribution
                  2, 2,             # Collision Buffer Distance
                  0.95, 0.50        # Learning Parameters
        )
    end
end

# Daniel Note: Updated the states and observations to Array{CartesianIndex}
struct ConnectPOMDP <: POMDP{Array{CartesianIndex}, Array{Symbol}, Array{CartesianIndex}}
    # Problem Setup
    num_agents::Int
    num_leaders::Int
    n_grid_size::Int

    # Rewards
    R_o::Int    # Negative reward for agent-obstacle collision
    R_a::Int    # Negative reward for agent-agent    collision
    R_λ::Int    # Negative reward for loss of connectivity

    # Motion and Sensing Uncertainty
    p_bins_observation::Array{Float64} # binned probabilities sorted largest-to-smallest

    # Connectivity Probability Distribution (Truncated Gaussian)
    connectivity_dist::Truncated

    # Transition probability distribution (Discrete Gaussian)
    p_bins_follower::Array{Float64} # binned probabilities sorted largest-to-smallest
    p_bins_leader::Array{Float64} # error-free transition function for leaders
    sp_order_table::Array{Int} # Lookup table for states sorted by probability of transition

    # Collision Buffer Distance (L-nfty Norm)
    object_collision_buffer::Int 
    agent_collision_buffer::Int

    γ::Float64 # Discount Factor

    """Constructor for ConnectPOMDP based on ParamsStruct"""
    function ConnectPOMDP(params::ParamsStruct)
        
        # compute discrete Gaussian bins for transition function
        p_bins_follower, p_bins_leader = compute_discrete_gaussian(params.σ_transition, params.b_transition)
        p_bins_observation, _ = compute_discrete_gaussian(params.σ_obs, params.b_obs)

        # computed truncated Gaussian distribution for connectivity
        trunc_normal = truncated(Normal(0, params.σ_transition), 
                                          -params.connect_thresh, 
                                           params.connect_thresh)

        # compute lookup table for state transitions
        sp_order_table = compute_sp_order_table()

        return new(params.num_agents, params.num_leaders, params.n_grid_size, 
                   params.R_o, params.R_a, params.R_λ, 
                   p_bins_observation, trunc_normal, 
                   p_bins_follower, p_bins_leader, sp_order_table,
                   params.object_collision_buffer, params.agent_collision_buffer, 
                   params.γ)
    end
end

function compute_discrete_gaussian(σ::Float64, b::Float64)
    # TODO: Generalize to different numbers of actions
    n_actions = 9
    
    # Use continuous, zero-mean Gaussian distribution to form discrete bins
    N = Distributions.Normal(0, σ)

    # compute the bin heights for the symmetric discrete gaussian
    p_bins = zeros(Float64, (n_actions))
    for i = 1:Int(ceil(n_actions/2))
        if i > 1
            # compute bins on either side of mean (symmetric for Gaussian)
            p_bins[2*i-2] = cdf(N, (-i+1)*b) - cdf(N, -i*b)
            p_bins[2*i-1]   = cdf(N, i*b) - cdf(N, (i-1)*b) 
        else
            # compute center (largest bin)
            p_bins[i] = cdf(N, i*b) - cdf(N, -i*b)
        end
    end

    p_bins_leader = zeros(n_actions)
    p_bins_leader[1] = 1.0

    # ensure that probabilities sum to 1
    return normalize!(p_bins, 1), p_bins_leader
end

"""
Compute lookup table of the ordering of state from highest chance of transition
to lowest chance of transition. See transitions.jl for more information.

Ordering for each action is stored as a column vector in sp_order_table
"""
function compute_sp_order_table()

    n_actions = 9

    sp_order_table = zeros(Int, (9,9))

    for k = 1:9
        if k < 9
            sp_order_table[:, k] = k .+ [0, 1, -1, 2, -2, 3, -3, -4, (17-k)]
            sp_order_table[sp_order_table[:,k] .<= 0, k] .+= 8
            sp_order_table[sp_order_table[:,k] .>= 9, k] .-= 8
        else
            sp_order_table[:, k] = [9, 1, 2, 3, 4, 5, 6, 7, 8]
        end
        
    end

    return sp_order_table
end