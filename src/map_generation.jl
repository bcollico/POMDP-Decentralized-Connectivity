
include("params.jl")

# The objective of this file is to set the obstacles in the POMDP problem

"""
    gen_rand_obstacle(n_grid::Int, grid_dimension::Int = 2)

Helper function to generate a single random obstacle.

### Inputs:
- n_grid            -- The size of the grid world (e.g., n_grid x n_grid for 2D)
- grid_dimension    -- The number of dimension (e.g, 2D, 3D, etc)

### Outputs:
- obstacle coordinates as a CartesianIndex
"""
function gen_rand_obstacle(n_grid_size::Int, grid_dimension::Int = 2)

    obstacle_coords = zeros(Int, grid_dimension)

    for d in 1:grid_dimension
        obstacle_coords[d] = rand(1:n_grid_size)
    end

    return CartesianIndex(obstacle_coords...)
end

"""
    gen_rand_obstacle(p::ParamsStruct)

Wrapper for ParamsStruct. See `gen_rand_obstacle(n_grid_size::Int, 
    grid_dimension::Int = 2)` for more details.
"""
function gen_rand_obstacle(p::ParamsStruct)
    gen_rand_obstacle(p.n_grid_size, p.grid_dimension)
end

"""
    gen_multiple_rand_obstacles(n_obstacles::Int, n_grid_size::Int,
                                     grid_dimension::Int = 2)

Generate multiple random obstacles

### Inputs:
- n_obstacles     -- The number of obstacles to generate
- n_grid          -- The size of the grid world (e.g., n_grid x n_grid for 2D)
- grid_dimension  -- The number of dimension (e.g, 2D, 3D, etc)

### Outputs:
- Array of obstacle coordinates as an Array{CartesianIndex}

"""
function gen_multiple_rand_obstacles(n_obstacles::Int, n_grid_size::Int,
                                     grid_dimension::Int = 2)
    all_obstacles = []
    for _ in 1:n_obstacles
        push!(all_obstacles, gen_rand_obstacle(n_grid_size, grid_dimension))
    end

    return all_obstacles
end

"""
    gen_multiple_rand_obstacles(p::ParamsStruct)

Wrapper for ParamsStruct. See `gen_multiple_rand_obstacles(n_obstacles::Int, 
    n_grid_size::Int, grid_dimension::Int = 2)` for more details.
"""
function gen_multiple_rand_obstacles(p::ParamsStruct)
    gen_multiple_rand_obstacles(p.n_obstacles, p.n_grid_size, p.grid_dimension)
end
