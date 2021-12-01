
include("plot_states.jl")

using Plots
# using GR
gr()

n = 50
n_obs = 100
n_agents = 1
n_leaders = 1

# ob_arr = gen_multiple_rand_obstacles(n_obs, n)
ob_arr = [
    CartesianIndex(18, 18),
CartesianIndex(24, 31),
CartesianIndex(8, 35),
CartesianIndex(50, 22),
CartesianIndex(46, 30),
CartesianIndex(9, 27),
CartesianIndex(14, 46),
CartesianIndex(44, 31),
CartesianIndex(46, 38),
CartesianIndex(26, 38),
CartesianIndex(38, 33),
CartesianIndex(3, 18),
CartesianIndex(11, 12),
CartesianIndex(1, 30),
CartesianIndex(32, 26),
CartesianIndex(6, 36),
CartesianIndex(13, 37),
CartesianIndex(44, 50),
CartesianIndex(38, 12),
CartesianIndex(39, 9),
CartesianIndex(32, 13),
CartesianIndex(39, 25),
CartesianIndex(39, 49),
CartesianIndex(39, 43),
CartesianIndex(2, 10),
CartesianIndex(11, 3),
CartesianIndex(24, 5),
CartesianIndex(43, 3),
CartesianIndex(4, 28),
CartesianIndex(3, 35),
CartesianIndex(44, 27),
CartesianIndex(12, 6),
CartesianIndex(46, 33),
CartesianIndex(29, 6),
CartesianIndex(43, 14),
CartesianIndex(1, 4),
CartesianIndex(49, 11),
CartesianIndex(43, 11),
CartesianIndex(14, 21),
CartesianIndex(45, 26),
CartesianIndex(7, 39),
CartesianIndex(7, 48),
CartesianIndex(47, 15),
CartesianIndex(46, 35),
CartesianIndex(21, 35),
CartesianIndex(40, 25),
CartesianIndex(23, 2),
CartesianIndex(18, 2),
CartesianIndex(12, 34),
CartesianIndex(4, 14),
CartesianIndex(42, 28),
CartesianIndex(37, 2),
CartesianIndex(28, 5),
CartesianIndex(16, 48),
CartesianIndex(45, 39),
CartesianIndex(42, 13),
CartesianIndex(32, 45),
CartesianIndex(49, 32),
CartesianIndex(26, 37),
CartesianIndex(48, 39),
CartesianIndex(40, 22),
CartesianIndex(22, 32),
CartesianIndex(30, 45),
CartesianIndex(15, 23),
CartesianIndex(34, 44),
CartesianIndex(47, 32),
CartesianIndex(37, 10),
CartesianIndex(9, 26),
CartesianIndex(44, 36),
CartesianIndex(18, 35),
CartesianIndex(17, 17),
CartesianIndex(9, 38),
CartesianIndex(34, 46),
CartesianIndex(1, 38),
CartesianIndex(9, 8),
CartesianIndex(17, 31),
CartesianIndex(30, 34),
CartesianIndex(20, 20),
CartesianIndex(14, 6),
CartesianIndex(35, 25),
CartesianIndex(40, 12),
CartesianIndex(46, 36),
CartesianIndex(48, 32),
CartesianIndex(48, 13),
CartesianIndex(14, 36),
CartesianIndex(50, 47),
CartesianIndex(38, 14),
CartesianIndex(19, 25),
CartesianIndex(5, 31),
CartesianIndex(39, 8),
CartesianIndex(35, 45),
CartesianIndex(21, 47),
CartesianIndex(50, 21),
CartesianIndex(22, 28),
CartesianIndex(47, 36),
CartesianIndex(42, 23),
CartesianIndex(30, 35),
CartesianIndex(49, 9),
CartesianIndex(39, 5),
CartesianIndex(9, 9)
]
ob_map = Map(ob_arr)
# base_map = get_base_grid(n)
# add_obstacles_to_grid!(base_map, ob_map)

states = (CartesianIndex(35, 35), CartesianIndex(25, 15))

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
savefig(fig, "./plots/example_grid_world-1-1-$(n).png")
