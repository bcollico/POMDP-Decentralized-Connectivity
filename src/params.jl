struct paramsStruct
    # Problem Setup
    n_agents::Int
    n_leaders::Int
    grid_size::Int

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
    transition_bin_width::Float64

    # Collision Buffer Distance (L-nfty Norm)
    object_collision_buffer::Int 
    agent_collision_buffer::Int

    # Learning Parameters
    γ::Float64  # Discount Factor, in range(0, 1)
    α::Float64  # Learning Factor, in range(0, 1)
end

struct connectPOMDP <: POMDP{Array{CartesianIndices}, Array{Symbol}, Array{CartesianIndices}}

end