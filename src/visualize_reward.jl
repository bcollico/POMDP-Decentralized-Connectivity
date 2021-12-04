using POMDPs
using FileIO, JLD2
using POMDPSimulators
using POMDPPolicies
using POMDPModelTools
using BeliefUpdaters

println("Adding dependencies")
# Include all the dependencies
include("aa228_final_project.jl")
include("plot_states.jl")
include("compute_connectivity.jl")
include("simulate_custom.jl")

using Plots
using Plots.PlotMeasures
# using GR
gr()

# Initialize the default parameters and make a POMDP from it
println("Instantiating the POMDP")

policy = load("qmdp_policy-1-1-10-ThursAfternoon.jld2", "policy")
connect_pomdp = policy.pomdp

k_iters = 100

# try to stepthrough
# for (s, a, r) in stepthrough(connect_pomdp, policy, "s,a,r", max_steps=10)
#     @show s
#     @show a
#     @show r
#     λ = compute_connectivity(s, connect_pomdp)
#     @show λ
#     println()
# end

# sd = POMDPs.initialstate_distribution(policy.pomdp)
sd = Deterministic{Tuple{CartesianIndex{2},CartesianIndex{2}}}((CartesianIndex(5, 5), CartesianIndex(8, 8)))

updater_ = updater(policy)
b_array = []
for i = connect_pomdp.num_agents
    push!(b_array, initialize_belief(updater_, sd))
end

# Test out belief
# b = initialize_belief(updater_, s)
# a = (:stay, :stay)
# o = rand(s)
# u = update(updater_, b, a, o)

function leader_actions()
    
end


s = rand(sd)

rewards = []
λs = []

for k in 1:k_iters
    global s
    global b_array
    #fig, base_grid = multiagent_grid_world_plot(policy.pomdp, rand(s))
    #println("Generated figure, now displaying the figure.")
    #display(fig)
    println("Iteration $(k) at state $(s)")
    println("believes to be at $(agent_belief(connect_pomdp, b_array[1]))")

    b_array, s, r, λ = our_simulate(policy, updater_, s, :stay, b_array)
    println("r = $(r), λ = $(λ) \n")

    push!(rewards, r)
    push!(λs, λ)
end


# Plot the reward 
# cumulative_reward = cumsum(rewards)

fig_r = plot(rewards, labels="QMDP Policy", 
    left_margin=15Plots.mm, bottom_margin=8Plots.mm)
xlabel!("Timesteps")
ylabel!("Rewards")
title!("Rewards over time")
display(fig_r)
println("Saving the reward figure.")
savefig(fig_r, "./plots/reward_timeseries-$(k_iters).png")

close_state = (CartesianIndex(1, 1), CartesianIndex(7, 1))

fig_λ = plot(λs ./ compute_connectivity(close_state, connect_pomdp), labels="QMDP Policy", 
    left_margin=15Plots.mm, bottom_margin=8Plots.mm)
xlabel!("Timesteps")
ylabel!("Connectivity Improvement")
title!("Connectivity Improvement over time")
display(fig_λ)
println("Saving the connectivity figure.")
savefig(fig_r, "./plots/connectivity_timeseries-$(k_iters).png")
