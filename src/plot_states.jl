using Plots
using CategoricalArrays

include("map_generation.jl")
include("params.jl")

"""
    get_base_grid(p::ParamsStruct)

Generate an empty 2D grid of the correct shape (``n × n``).

### Inputs:
- n       -- Size of the grid `n`

### Outputs:
- grid of zeros as an Array{Float64, 2}
"""
function get_base_grid(n_grid_size::Int)
    # An zero'ed grid of size n x n
    return zeros(Int, n_grid_size, n_grid_size)
end

"""
    get_base_grid(p::ParamsStruct)

Wrapper with ParamsStruct.

See `get_base_grid(n_grid_size::Int)` for full details.
"""
get_base_grid(p::ParamsStruct) = get_base_grid(p.n_grid_size)

"""
    add_obstacles_to_grid!(base_grid, obstacles_map::map)

Include the obstacles in the grid.

### Inputs:
- base_grid       -- Generated from `get_base_grid`
- obstacles_map   -- The map with with obstacle locations

### Outputs:
- None, in-place
"""
function add_obstacles_to_grid!(base_grid, obstacles_map::map)
    # Now place the obstacles
    for obstacle_location in obstacles_map.obstacleLocations
        base_grid[obstacle_location] = -2
    end
end

"""
    add_bots_to_grid!(base_grip, s::Array{CartesianIndex{2}, 1}, 
                        num_agents::Int, num_leaders::Int)

Include the robots in the grid.

### Inputs:
- base_grid     -- Generated from `get_base_grid`
- state         -- The states of the robots

### Outputs:
- None, in-place
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

"""
    add_bots_to_grid!(base_grid, s::Array{CartesianIndex{2}, 1}, 
                            p::ParamsStruct)

Wrapper with ParamsStruct.

See `add_bots_to_grid!(base_grip, s::Array{CartesianIndex{2}, 1}, 
num_agents::Int, num_leaders::Int)` for full details.
"""
function add_bots_to_grid!(base_grid, s::Array{CartesianIndex{2}, 1}, 
                            p::ParamsStruct)
    add_bots_to_grid!(base_grid, s, p.num_agents, p.num_leaders)
end

function add_bots_to_grid!(base_grid, s::Tuple, 
    num_agents::Int, num_leaders::Int)
    add_bots_to_grid!(base_grid, [s...], num_agents, num_leaders)
end

function add_bots_to_grid!(base_grid, s::Tuple, p::ParamsStruct)
    add_bots_to_grid!(base_grid, [s...], p.num_agents, p.num_leaders)
end

"""
    int_to_category(value::Int)

Match an integer to a specific category. Functionally acts as a dictionary. 
This is really a patch to the convention used in prior functions. A rewrite
should just use the CategoricalArray throughout rather than redefining it here.

### Inputs:
- value     -- An integer identifier to match to a category.

### Outputs:
- category corresponding to the value, i.e., one of the following:
["Empty", "Obstacle", "Follower Agent", "Leader"]. An unexpected integer will
return "Not implemented".

"""
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

"""

Convert a base grid (2D integer array) into a list of x coordinates, 
y coordinates, and categories. 

### Inputs:
- base_grid     -- 2D integer array expressing the grid world

### Outputs:
- xs                -- The x coordinate at each point in the grid
- ys                -- The y coordinate at each point in the grid
- categories_grid   -- The category of the cell (x, y)

Note that xs, ys, and categories_grid all have the same dimension: `(n × n) × 1`
where `n` is the size of the grid.
"""
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

"""
    multiagent_grid_world_plot(n_grid_size::Int, obstacles_map::map, 
                                s::Array{CartesianIndex{2}, 1}, 
                                num_agents::Int, num_leaders::Int)

Plot the grid world with obstacles and agent/leader states.

### Inputs:
- n_grid_size       -- Specify that the grid is `n_grid_size × n_grid_size`
- obstacles_map     -- Location of obstacles. See `map`
- s                 -- States of agents and leaders
- num_agents        -- Number of agents
- num_leaders       -- Number of leaders

### Outputs:
- fig               -- The output figure
- base_grid         -- Populated grid of the grid world

Note that many parameters are "hard-coded" for plotting. A future implementation
can clean this up.
"""
function multiagent_grid_world_plot(n_grid_size::Int, obstacles_map::map, 
                                    s::Array{CartesianIndex{2}, 1}, 
                                    num_agents::Int, num_leaders::Int)
    base_grid = get_base_grid(n_grid_size)
    add_obstacles_to_grid!(base_grid, obstacles_map)

    add_bots_to_grid!(base_grid, s, num_agents, num_leaders)

    xs, ys, categories = get_categorical_representation(base_grid)

    fig = plot(xs, ys, group = categories, 
            seriestype = :scatter, # aspect_ratio = :equal,
            markersize = 14, markershape = :square,
            legend = :outertopright, #, markerstrokewidth=0.0) 
            margin = 8Plots.mm,
            color_palette = palette([:white, :orange, :green, :black], 4),
            xlim = (0.5, 0.5 + n), ylim = (0.5, 0.5 + n),
            xticks = 1:n, yticks = 1:n,
            xlabel = "X", ylabel = "Y", title = "Multi Agent Grid World")
    
    return fig, base_grid
end

"""
    multiagent_grid_world_plot(params::ParamsStruct, obstacles_map::map, 
                                s::Array{CartesianIndex{2}, 1})

Wrapper with ParamsStruct.

See `multiagent_grid_world_plot(n_grid_size::Int, obstacles_map::map, 
s::Array{CartesianIndex{2}, 1}, num_agents::Int, num_leaders::Int)` for full 
details.
"""
function multiagent_grid_world_plot(params::ParamsStruct, obstacles_map::map, 
    s::Array{CartesianIndex{2}, 1})
    return multiagent_grid_world_plot(params.n_grid_size, obstacles_map,
                                    s, params.num_agents, params.num_leaders)
end

function multiagent_grid_world_plot(n_grid_size::Int, obstacles_map::map, 
                                    s::Tuple, 
                                    num_agents::Int, num_leaders::Int)
    return multiagent_grid_world_plot(n_grid_size, obstacles_map, [s...],
                                    num_agents, num_leaders)
end

function multiagent_grid_world_plot(params::ParamsStruct, obstacles_map::map, 
    s::Tuple)
    return multiagent_grid_world_plot(params.n_grid_size, obstacles_map,
                                [s...], params.num_agents, params.num_leaders)
end
