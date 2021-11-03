using POMDPs

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
                  10, 5, 2,         # Map Parameters
                 -1e4, -1e4, -1e3,  # Rewards
                  0.0, 0.0,         # Motion and Sensing Uncertainty
                  1.0, 2,           # Connectivity Probability Distribution
                  1.0, 1.0,         # Transition probability distribution
                  2, 2,             # Collision Buffer Distance
                  0.95, 0.50        # Learning Parameters
        )
    end
end

struct ConnectPOMDP <: POMDP{Array{CartesianIndices}, Array{Symbol}, Array{CartesianIndices}}
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
    σ_connect::Float64  # Standard deviation
    connect_thresh::Int # Maximum distance threshold for connectivity

    # Transition probability distribution (Discrete Gaussian)
    σ_transition::Float64
    transition_bin_width::Float64

    # Collision Buffer Distance (L-nfty Norm)
    object_collision_buffer::Int 
    agent_collision_buffer::Int

    γ::Float64 # Discount Factor

    """Constructor for ConnectPOMDP based on ParamsStruct"""
    function ConnectPOMDP(params::ParamsStruct)
        return new(params.num_agents, params.num_leaders, params.n_grid_size, 
                   params.R_o, params.R_a, params.R_λ, params.σ_obs, params.σ_motion, 
                   params.σ_connect, params.connect_thresh, params.σ_transition, 
                   params.transition_bin_width, params.object_collision_buffer, 
                   params.agent_collision_buffer, params.γ)
    end
end