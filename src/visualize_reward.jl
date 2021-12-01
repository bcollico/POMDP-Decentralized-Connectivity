using POMDPs
using FileIO, JLD2
using POMDPSimulators
using POMDPPolicies
using POMDPModelTools

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

policy = load("qmdp_policy.jld2", "policy.jl")
connect_pomdp = policy.pomdp

# try to stepthrough
# for (s, a, r) in stepthrough(connect_pomdp, policy, "s,a,r", max_steps=10)
#     @show s
#     @show a
#     @show r
#     λ = compute_connectivity(s, connect_pomdp)
#     @show λ
#     println()
# end

s = POMDPs.initialstate_distribution(policy.pomdp)

for _ in 1:10
    global s
    println("currently at $(rand(s))")
    fig, base_grid = multiagent_grid_world_plot(policy.pomdp, rand(s))
    println("Generated figure, now displaying the figure.")
    display(fig)

    s, r, λ = our_simulate(policy, s, :stay)
    println("r = $(r), λ = $(λ)")
end
