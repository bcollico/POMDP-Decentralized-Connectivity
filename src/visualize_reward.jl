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

# policy = load("qmdp_policy-1-1-10-ThursAfternoon.jld2", "policy")
policy = load("qmdp_policy_pomdp.jld2", "policy")
connect_pomdp = policy.pomdp

# Make a random policy
rand_policy = RandomPolicy(connect_pomdp)

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
sd = Deterministic{Tuple{CartesianIndex{2},CartesianIndex{2}}}(
    (CartesianIndex(1, 9), CartesianIndex(8, 8)))

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

function leader_actions(index, flip)
    if flip
        # if mod(index, 2) == 1
        #     return :north 
        # else
        #     return :west 
        # end
        # return :northwest
        if mod(index, 2) == 1
            return :stay 
        else
            return :northwest 
        end
    else
        # if mod(index, 2) == 1
        #     return :south 
        # else
        #     return :east 
        # end
        # return :southeast
        if mod(index, 2) == 1
            return :stay 
        else
            return :southeast 
        end
    end
end


s = rand(sd)

rewards = []
rand_rewards = []
λs = []
rand_λs = []

flip = false

###############
# With our policy
###############
for k in 1:k_iters
    global s
    global b_array
    global flip
    #fig, base_grid = multiagent_grid_world_plot(policy.pomdp, rand(s))
    #println("Generated figure, now displaying the figure.")
    #display(fig)
    println("Iteration $(k) at state $(s)")
    println("believes to be at $(agent_belief(connect_pomdp, b_array[1]))")

    leader_a = leader_actions(k, flip)

    b_array, s, r, λ = our_simulate(policy, updater_, s, leader_a, b_array)
    println("r = $(r), λ = $(λ) \n")

    push!(rewards, r)
    push!(λs, λ)

    if s[1] == CartesianIndex(9, 1)
        flip = true
    elseif s[1] == CartesianIndex(1, 9)
        flip = false
    end
end

################
# With Random
################
for k in 1:k_iters
    global s
    global b_array
    global flip
    #fig, base_grid = multiagent_grid_world_plot(policy.pomdp, rand(s))
    #println("Generated figure, now displaying the figure.")
    #display(fig)
    println("Iteration $(k) at state $(s)")
    println("believes to be at $(agent_belief(connect_pomdp, b_array[1]))")

    leader_a = leader_actions(k, flip)

    b_array, s, r, λ = our_simulate_random(rand_policy, connect_pomdp, updater_, s, leader_a, b_array)
    println("r = $(r), λ = $(λ) \n")

    push!(rand_rewards, r)
    push!(rand_λs, λ)

    if s[1] == CartesianIndex(9, 1)
        flip = true
    elseif s[1] == CartesianIndex(1, 9)
        flip = false
    end
end

# Plot the reward 
# cumulative_reward = cumsum(rewards)

fig_r = plot(rewards, labels="QMDP Policy", 
    left_margin=15Plots.mm, bottom_margin=8Plots.mm, legend=:bottomleft)
plot!(rand_rewards, labels="Random Policy")
xlabel!("Timesteps")
ylabel!("Rewards")
title!("Rewards over time")
display(fig_r)
println("Saving the reward figure.")
savefig(fig_r, "./plots/reward_timeseries-pomdp-moving-stay-$(k_iters).png")

close_state = (CartesianIndex(1, 1), CartesianIndex(7, 1))

λimprove(λ) = max.(λ, 1e-10) ./ compute_connectivity(close_state, connect_pomdp)
λimprove_qmdp = λimprove(λs)
λimprove_rand = λimprove(rand_λs)

fig_λ = plot(λimprove_qmdp, labels="QMDP Policy", yaxis=:log, 
    left_margin=15Plots.mm, bottom_margin=8Plots.mm, legend=:topleft)
plot!(λimprove_rand, labels="Random Policy")
hline!([1], color=:black, linestyle=:dash, labels="Connectivity Boundary")
hline!([1e-10 / compute_connectivity(close_state, connect_pomdp)], color=:black, linestyle=:dot, labels="No Connectivity")
xlabel!("Timesteps")
ylabel!("Connectivity Improvement")
ylims!(10^(-2.2), 1e12)
title!("Connectivity Improvement over time")
display(fig_λ)
println("Saving the connectivity figure.")
savefig(fig_λ, "./plots/connectivity_timeseries-pomdp-moving-stay-$(k_iters).png")
