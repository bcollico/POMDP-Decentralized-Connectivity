using POMDPs

include("params.jl")

# The objective of this file is to set the state handling capabilities of the
# POMDP problem

# POMDP is ConnectPOMDP

"""

The ConnectPOMDP is specified over an `n` x `n` grid world, where `n` is the 
`n_grid_size` variable in the POMDP. There are `num_bots` total robots which
include the agents (followers) and passive robots (leaders). So, we have a 
(`n` x `n`) x `num_bots` state space.

Each state is an array of CartesianIndex for each robot.

Inputs:
    pomdp   The ConnectPOMDP instance

Outputs:
    𝒮       The full state space
"""
function POMDPs.states(pomdp::ConnectPOMDP)
    # The Grid Size (i.e., n_grid_size x n_grid_size)
    n_grid_size = pomdp.n_grid_size

    # Total number of robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    # The full state space 𝒮
    return [CartesianIndices(ones(n_grid_size, n_grid_size)) for k in 1:num_bots]
end 

"""
    POMDPs.stateindex(pomdp::ConnectPOMDP, s::Tuple{Int, Int})

Map a state (x, y) to a linear index. This function inherets from the POMDPs
stateindex funtion. 

Inputs:
    pomdp   The ConnectPOMDP index 
    s       The probed state

Outputs:
    The state index
"""
function POMDPs.stateindex(pomdp::ConnectPOMDP, s::Array{CartesianIndices})
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
        bot_indices[bot] = li[s[bot][1], s[bot][2]]
    end

    # Outer dimension is (n x n)^(num_bots)
    outer_bot_num_dimension = Tuple([n_grid_size_flat for bot in 1:num_bots])

    # Output the unique number that describes that state array
    return LinearIndices(outer_bot_num_dimension)bot_indices
end
