struct ParamsStruct
    # Problem Setup
    num_agents::Int
    num_leaders::Int

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
end

function ParamsStruct()

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
end

function ConnectPOMDP(params::ParamsStruct)
       # Problem Setup
       num_agents  = params.num_agents
       num_leaders = params.num_leaders
       n_grid_size = params.n_grid_size
   
       # Rewards
       R_o = params.R_o    # Negative reward for agent-obstacle collision
       R_a = params.R_a    # Negative reward for agent-agent    collision
       R_λ = params.R_λ    # Negative reward for loss of connectivity
   
       # Motion and Sensing Uncertainty
       σ_obs    = params.σ_obs    # Standard deviation of Gaussian measurement noise
       σ_motion = params.σ_motion # Standard deviation of Gaussian process     noise
   
       # Connectivity Probability Distribution (Truncated Gaussian)
       σ_connect      = params.σ_connect  # Standard deviation
       connect_thresh = params.connect_thresh # Maximum distance threshold for connectivity
   
       # Transition probability distribution (Discrete Gaussian)
       σ_transition = params.σ_transition
       transition_bin_width = params.transition_bin_width
   
       # Collision Buffer Distance (L-nfty Norm)
       object_collision_buffer = params.object_collision_buffer
       agent_collision_buffer = params.agent_collision_buffer
   
       γ = params.γ # Discount Factor
end