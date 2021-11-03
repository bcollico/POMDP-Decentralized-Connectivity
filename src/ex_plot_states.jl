
include("plot_states.jl")

using Plots
# using GR
gr()

n = 10
n_obs = 6
n_agents = 4
n_leaders = 2

ob_arr = gen_multiple_rand_obstacles(n_obs, n)
ob_map = map(ob_arr)
# base_map = get_base_grid(n)
# add_obstacles_to_grid!(base_map, ob_map)

states = [CartesianIndex(2, 2), CartesianIndex(5, 6), CartesianIndex(10, 6),
            CartesianIndex(8, 9), CartesianIndex(4, 7), CartesianIndex(9, 3)]

# add_bots_to_grid!(base_map, states, n_agents, n_leaders)

# xs, ys, categories = get_categorical_representation(base_map)

# fig = plot(xs, ys, group = categories, 
#         seriestype = :scatter, # aspect_ratio = :equal,
#         markersize = 14, markershape = :square,
#         legend = :outertopright, #, markerstrokewidth=0.0) 
#         margin = 8Plots.mm,
#         color_palette = palette([:white, :orange, :green, :black], 4),
#         xlim = (0.5, 0.5 + n), ylim = (0.5, 0.5 + n),
#         xticks = 1:n, yticks = 1:n,
#         xlabel = "X", ylabel = "Y", title = "Multi Agent Grid World")

fig, base_map = multiagent_grid_world_plot(n, ob_map, states, 
                                            n_agents, n_leaders)
println("Generated figure, now displaying the figure.")
display(fig)
println("Saving the figure.")
savefig(fig, "./plots/example_grid_world.png")
