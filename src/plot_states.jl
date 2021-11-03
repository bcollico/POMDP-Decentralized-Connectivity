using Plots
using CategoricalArrays

include("map_generation.jl")
# include("states.jl")

"""
    get_base_grid(p::ParamsStruct)

Generate an empty 2D grid of the correct shape (n x n).

Inputs:
    n       Size of the grid `n`

Outputs:
    grid of zeros as an Array{Float64, 2}
"""
function get_base_grid(n_grid_size::Int)
    # An zero'ed grid of size n x n
    return zeros(Int, n_grid_size, n_grid_size)
end

get_base_grid(p::ParamsStruct) = get_base_grid(p.n_grid_size)

"""
    add_obstacles_to_grid!(base_grid, obstacles_map::map)

Include the obstacles in the grid.

Inputs:
    base_grid       Generated from `get_base_grid`
    obstacles_map   The map with with obstacle locations

Outputs:
    None, in-place
"""
function add_obstacles_to_grid!(base_grid, obstacles_map::map)
    # Now place the obstacles
    for obstacle_location in obstacles_map.obstacleLocations
        base_grid[obstacle_location] = -2
    end
end

"""
    add_bots_to_grid!(base_grip, s::Array{CartesianIndices})

Include the robots in the grid.

Inputs:
    base_grid       Generated from `get_base_grid`
    state           The states of the robots

Outputs:
    None, in-place
"""
function add_bots_to_grid!(base_grid, s::Array{CartesianIndex{2}, 1}, 
                            num_agents::Int, num_leaders::Int)
    # Now place the agents
    for agent_ind in 1:num_agents
        agent_location = s[agent_ind]
        base_grid[agent_location] = 1
    end

    # Now place the leaders
    for leader_ind in 1:num_leaders
        leader_location = s[leader_ind + num_agents]
        base_grid[leader_location] = 2
    end
end

function add_bots_to_grid!(base_grid, s::Array{CartesianIndex{2}, 1}, 
                            p::ParamsStruct)
    add_bots_to_grid!(base_grid, s, p.num_agents, p.num_leaders)
end


function int_to_category(value::Int)
    if value == 0
        return "Empty"    
    elseif value == -2
        return "Obstacle"
    elseif value == 1
        return "Follower Agent"
    elseif value == 2
        return "Leader"
    else
        return "Not implemented"
    end
end

function get_categorical_representation(base_grid)

    xs = []
    ys = []
    categories_grid = []

    n_rows, n_cols = size(base_grid)

    for r in 1:n_rows
        for c in 1:n_cols
            value = base_grid[r, c]
            cat = int_to_category(value)

            push!(xs, r)
            push!(ys, c)
            push!(categories_grid, cat)
        end
    end

    return xs, ys, CategoricalArray(categories_grid)
end
