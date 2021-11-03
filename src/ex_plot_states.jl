
include("plot_states.jl")

using Plots
# using GR
gr()

n = 10
n_obs = 3
n_agents = 2
n_leaders = 1

ob_arr = gen_multiple_rand_obstacles(n_obs, n)
ob_map = map(ob_arr)
base_map = get_base_grid(10)
add_obstacles_to_grid!(base_map, ob_map)

states = [CartesianIndex(2, 2), CartesianIndex(4, 2), CartesianIndex(10, 6)]

add_bots_to_grid!(base_map, states, n_agents, n_leaders)

# hm = heatmap(1:n, 1:n, base_map, 
#                 aspect_ratio=:equal,
#                 framestyle=:box,
#                 tickdirection=:out,
#                 c = :rainbow,
#                 levels = 5)


# xlims!(0.5, n + 0.5)

# plot(base_map)

xs, ys, categories = get_categorical_representation(base_map)

fig = plot(xs, ys, group = categories, 
        seriestype = :scatter, # aspect_ratio = :equal,
        markersize = 14, markershape = :square,
        legend = :outertopright, #, markerstrokewidth=0.0) 
        margin = 8Plots.mm,
        color_palette = palette([:white, :orange, :green, :black], 4),
        xlim = (0.5, 0.5 + n), ylim = (0.5, 0.5 + n),
        xticks = 1:n, yticks = 1:n,
        xlabel = "X", ylabel = "Y", title = "Multi Agent Grid World")

savefig(fig,"./plots/example_grid_world.png")
