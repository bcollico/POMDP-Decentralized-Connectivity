
# The objective of this file is to set the obstacles in the POMDP problem

"""
    map

Store the map of the obstacle locations. Each obstacle is represented with a 
CartesianIndex.
"""
struct map
    obstacleLocations::Array{CartesianIndex}
end

"""
    gen_rand_obstacle(n_grid::Int, grid_dimension::Int = 2)

Helper function to generate a single random obstacle.

Inputs:
    n_grid          The size of the grid world (e.g., n_grid x n_grid for 2D)
    grid_dimension  The number of dimension (e.g, 2D, 3D, etc)

Outputs:
    obstacle coordinates as a CartesianIndex
"""
function gen_rand_obstacle(n_grid::Int, grid_dimension::Int = 2)

    obstacle_coords = zeros(Int, grid_dimension)

    for d in 1:grid_dimension
        obstacle_coords[d] = rand(1:n_grid)
    end

    return CartesianIndex(obstacle_coords...)
end

"""

Generate multiple random obstacles

Inputs:
    n_obstacles     The number of obstacles to generate
    n_grid          The size of the grid world (e.g., n_grid x n_grid for 2D)
    grid_dimension  The number of dimension (e.g, 2D, 3D, etc)

Outputs:
    Array of obstacle coordinates as an Array{CartesianIndex}

"""
function gen_multiple_rand_obstacles(n_obstacles::Int, n_grid::Int,
                                     grid_dimension::Int = 2)
    all_obstacles = []
    for _ in 1:n_obstacles
        push!(all_obstacles, gen_rand_obstacle(n_grid, grid_dimension))
    end

    return all_obstacles
end
