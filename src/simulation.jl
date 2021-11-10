using POMDPPolicies
using POMDPSimulators
using POMDPModelTools
using Distributions
using Random

# Add random sampling support for 
Random.rand(d::SparseCat, n::Int) = [rand(d) for _ in 1:n]
Random.rand(rng::AbstractRNG, d::SparseCat, n::Int) = [rand(rng, d) for _ in 1:n]

# Include all the dependencies
include("aa228_final_project.jl")

# Initialize the default parameters and make a POMDP from it
p = ParamsStruct()
connect_pomdp = ConnectPOMDP(p)

# Make a random policy
rand_policy = RandomPolicy(connect_pomdp)

# print(rand_policy)

print("Pick the action of the initial state: ")
s_first = POMDPs.initialstate(connect_pomdp)
a_rand_first = action(rand_policy, s_first)
println(a_rand_first)

println("Check Transition")
t_first = POMDPs.transition(connect_pomdp, s_first, a_rand_first)
println(t_first)
println("Example Samples")
println(rand(t_first, 3))

println("Check Observation")
o_first = POMDPs.observation(connect_pomdp, a_rand_first, s_first)
println(o_first)
println("Example Samples")
println(rand(o_first, 3))

# Now try to stepthrough
for (s, a, r) in stepthrough(connect_pomdp, rand_policy, "s,a,r", max_steps=10)
    @show s
    @show a
    @show r
    println()
end

# num_steps = 10

# action_hard = (:west, :east)

# num_bots = connect_pomdp.num_agents + connect_pomdp.num_leaders

# current_states = POMDPs.initialstate_distribution(connect_pomdp)
# println("started at")
# println(current_states)

# for _ in  1:num_steps
#     # Transition
#     global current_states
#     # println("currently at")
#     # println(current_states)
#     t_prob = transition(connect_pomdp, current_states, action_hard)
#     # print("Transition Probability")
#     # println(t_prob)

#     new_state = []

#     for n = 1:num_bots
#         # Sample t_prob
#         relative_new_states = rand(t_prob[n], 1)[1]
#         # print("relative: ")
#         # println(relative_new_states)
        
#         # Get the reachable states
#         reachable_s_bot = compute_reachable_states(current_states[n])
#         # get the reachable state that matches the realization of the transition
#         # distribution
#         # print("reachable: ")
#         # println(reachable_s_bot)
#         # println(reachable_s_bot[relative_new_states])

#         # print("Previously at ")
#         # println(current_states[n])
#         push!(new_state, reachable_s_bot[relative_new_states])
#         # print("New state for robot ")
#         # print(n)
#         # print(" is ")
#         # println(new_state[n])
#     end

#     current_states = Tuple(new_state)
#     print("New states: ")
#     println(current_states)
# end
