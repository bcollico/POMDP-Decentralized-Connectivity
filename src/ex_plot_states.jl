
include("plot_states.jl")

gr()

n = 10
n_obs = 3

ob_arr = gen_multiple_rand_obstacles(n_obs, n)
ob_map = map(ob_arr)
base_map = get_base_grid(10)
add_obstacles_to_grid!(base_map, ob_map)

hm = heatmap(1:n, 1:n, base_map, 
                aspect_ratio=:equal,
                framestyle=:box,
                tickdirection=:out)


xlims!(0.5, n + 0.5)
