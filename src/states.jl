using POMDPs

include("params.jl")

# The objective of this file is to set the state handling capabilities of the
# POMDP problem. Our POMDP is the ConnectPOMDP

"""
    POMDPs.states(pomdp::ConnectPOMDP)

The ConnectPOMDP is specified over an `n × n` grid world, where `n` is the 
`n_grid_size` variable in the POMDP. There are `num_bots` total robots which
include the agents (followers) and passive robots (leaders). So, we have a 
`(n × n) × num_bots` state space.

Each state is an array of CartesianIndex for each robot.

### Inputs:
- pomdp     -- The ConnectPOMDP instance

### Outputs:
- 𝒮         -- The full state space represented as an array of CartesianIndices

### Note:
This function currently assumes a 2D grid, not a 3D grid.
"""
function POMDPs.states(pomdp::ConnectPOMDP)
    # The Grid Size (i.e., n_grid_size x n_grid_size)
    n_grid = pomdp.n_grid_size

    # Total number of robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    # The full state space 𝒮
    S_arr = [CartesianIndices(ones(n_grid, n_grid)) for _ in 1:num_bots]
    return collect(Base.product(S_arr...))
end 

"""
    POMDPs.stateindex(pomdp::ConnectPOMDP, s::Array{CartesianIndex})

Map a state to a linear index. This function inherits from the POMDPs
stateindex funtion. The total state space is an array of CartesianIndices (See
`POMDPs.states(pomdp::ConnectPOMDP)` for more information). A given state is a 
one dimensional array of CartesianIndex values. Each CartesianIndex is the
(x, y) location of a robot on the grid. These CartesianIndex values are stacked
into the state vector. 

### Inputs:
- pomdp     -- The ConnectPOMDP index 
- s         -- The requested state

### Outputs:
- The state index (unique mapping from 𝒮 → 𝒩 (nonzero natural numbers))

### Note:
This function currently assumes a 2D grid, not a 3D grid.
"""
function POMDPs.stateindex(pomdp::ConnectPOMDP, s::Tuple)
    # The Grid Size (i.e., n_grid_size x n_grid_size)
    n_grid_size = pomdp.n_grid_size
    # The total grid size is n_grid_size_flat = n_grid_size x n_grid_size
    n_grid_size_flat = n_grid_size * n_grid_size
    # Total number of robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    # LinearIndices instance that represents a single grid
    li = LinearIndices((n_grid_size, n_grid_size))

    # Stores the LinearIndices of the grid for each robot
    bot_indices = zeros(num_bots)
    for bot in 1:num_bots
        # Calculate the LinearIndices of the grid for each robot
        # s[bot] is a CartesianIndex
        # s[bot][1] is the first value of CartesianIndex
        bot_indices[bot] = li[s[bot][1], s[bot][2]]
    end

    # Outer dimension is (n x n)^(num_bots)
    outer_bot_num_dimension = Tuple([n_grid_size_flat for bot in 1:num_bots])

    # Output the unique number that describes that state array
    return LinearIndices(outer_bot_num_dimension)[bot_indices...]
end
