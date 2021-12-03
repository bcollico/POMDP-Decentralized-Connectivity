using POMDPs
using FileIO, JLD2
using POMDPSimulators

println("Adding dependencies")
# Include all the dependencies
include("aa228_final_project.jl")
include("plot_states.jl")

using Plots
using Plots.PlotMeasures
# using GR
gr()

# Initialize the default parameters and make a POMDP from it
println("Instantiating the POMDP")

policy = load("qmdp_policy-1-1-10-ThursAfternoon.jld2", "policy")
connect_pomdp = policy.pomdp

# For the initial state distribution
sinit_dist = POMDPs.initialstate_distribution(connect_pomdp)
sinit = rand(sinit_dist)

# The leader is fixed
s_leader = CartesianIndex(9, 9)

# The follower is variable
# Initialize U (table of value function) and a (table of best action)
U = zeros(connect_pomdp.n_grid_size, connect_pomdp.n_grid_size)
a = zeros(Int64, connect_pomdp.n_grid_size, connect_pomdp.n_grid_size)

# Order the actions 
ord_a = ordered_actions(connect_pomdp)
# Get the actions that correspond with a stationary leader
stay_ord_a = [ord_a[x * 9] for x in 1:9]
num_alphas = length(policy.alphas)

for row in 1:connect_pomdp.n_grid_size
    for col in 1:connect_pomdp.n_grid_size
        s_follower = CartesianIndex(col, row)
        s_full = (s_leader, s_follower)
        s_follower_ind = POMDPs.stateindex(connect_pomdp, s_full)
        
        best_aind = 9 * argmax([policy.alphas[aind][s_follower_ind] for aind in 9:9:num_alphas])
        best_u = policy.alphas[best_aind][s_follower_ind]

        U[row, col] = best_u
        a[row, col] = best_aind
    end
end

println("Determined U. Generating heatmap")
fig = heatmap(log.(-U.+1e-10), margin=9Plots.mm, 
    c=cgrad(:heat, rev=false))
# display(fig)

function map_named_to_letters(a)
    if a == :east;          return "→" # "E"
    elseif a == :northeast; return "↗" # "NE"
    elseif a == :north;     return "↑" # "N"
    elseif a == :northwest; return "↖" # "NW"
    elseif a == :west;      return "←" # "W"
    elseif a == :southwest; return "↙" # "SW"
    elseif a == :south;     return "↓" # "S"
    elseif a == :southeast; return "↘" # "SE"
    elseif a == :stay;      return "X"
    end
end


for row in 1:connect_pomdp.n_grid_size
    for col in 1:connect_pomdp.n_grid_size
        which_action_pair = ord_a[a[row, col]]
        letter = map_named_to_letters(which_action_pair[2])
        annotate!(col, row, letter)
    end
end

xlabel!("x")
ylabel!("y")
title!("Best Follower Action for Stationary Leader")

ob_arr = [CartesianIndex(3,3), CartesianIndex(4,3), CartesianIndex(7,7), CartesianIndex(7,6)]

box_rect(x, y) = Shape(x .+ [-0.5,0.5,0.5,-0.5], y .+ [-0.5,-0.5,0.5,0.5])
plot_obj_box(x, y, line_style) = plot!(obs_rect(x, y), fillcolor=:transparent, 
    linecolor="black", linestyle=line_style, linewidth=4, legend=false)

# Show the obstacles
for ob in ob_arr
    plot_obj_box(ob[1], ob[2], :solid)
end

# Show the leader
plot_obj_box(s_leader[1], s_leader[2], :dot)
plot!(size=(580,500))
display(fig)
println("Saving the figure.")
savefig(fig, "./plots/policy-plot-stationary-log-heat-border-equal-Arrows-($(s_leader[1])-$(s_leader[2])).png")

# Now try to stepthrough
# for (s, a, r) in stepthrough(connect_pomdp, policy, "s,a,r", max_steps=10)
#     @show s
#     @show a
#     @show r
#     println()

#     fig, base_map = multiagent_grid_world_plot(connect_pomdp, s)
#     println("Generated figure, now displaying the figure.")
#     display(fig)
# end
