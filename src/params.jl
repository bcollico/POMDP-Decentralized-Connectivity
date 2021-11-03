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

    # Motion and Sensing Uncertainty
    σ_obs::Float64    # Standard deviation of Gaussian measurement noise
    σ_motion::Float64 # Standard deviation of Gaussian process     noise

    # Connectivity Probability Distribution (Truncated Gaussian)
    σ_connect::Float64  # Standard deviation
    connect_thresh::Int # Maximum distance threshold for connectivity

    # Transition probability distribution (Discrete Gaussian)
    σ_transition::Float64
    transition_bin_width::Float64

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
                  0.0, 0.0,         # Motion and Sensing Uncertainty
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
    σ_obs::Float64    # Standard deviation of Gaussian measurement noise
    σ_motion::Float64 # Standard deviation of Gaussian process     noise

    # Connectivity Probability Distribution (Truncated Gaussian)
    connectivity_dist::Truncated

    # Transition probability distribution (Discrete Gaussian)
    p_transition_bins::Array{Float64} # binned probabilities sorted largest-to-smallest

    # Collision Buffer Distance (L-nfty Norm)
    object_collision_buffer::Int 
    agent_collision_buffer::Int

    γ::Float64 # Discount Factor

    """Constructor for ConnectPOMDP based on ParamsStruct"""
    function ConnectPOMDP(params::ParamsStruct)
        
        # compute discrete Gaussian bins for transition function
        p_bins = compute_transition_function(params)

        # computed truncated Gaussian distribution for connectivity
        trunc_normal = truncated(Normal(0, params.σ_transition), 
                                          -params.connect_thresh, 
                                           params.connect_thresh)

        return new(params.num_agents, params.num_leaders, params.n_grid_size, 
                   params.R_o, params.R_a, params.R_λ, 
                   params.σ_obs, params.σ_motion, trunc_normal, p_bins, 
                   params.object_collision_buffer, params.agent_collision_buffer, 
                   params.γ)
    end
end

function compute_transition_function(params::ParamsStruct)
    # TODO: Generalize to different numbers of actions
    n_actions = params.grid_dimension^3 + 1
        
    σ_transition = params.σ_transition
    b = params.transition_bin_width
    
    # Use continuous, zero-mean Gaussian distribution to form discrete bins
    N = Distributions.Normal(0, σ_transition)

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

    # ensure that probabilities sum to 1
    return normalize!(p_bins, 1)
end