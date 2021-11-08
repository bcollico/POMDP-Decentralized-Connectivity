using POMDPPolicies
using POMDPSimulators
using Distributions

include("aa228_final_project.jl")

p = ParamsStruct()
connect_pomdp = ConnectPOMDP(p)

rand_policy = RandomPolicy(connect_pomdp)

# print(rand_policy)

# for (s, a, r) in stepthrough(connect_pomdp, rand_policy, "s,a,r", max_steps=10)
#     @show s
#     @show a
#     @show r
#     println()
# end

num_steps = 10

action_hard = [:east, :west]

num_bots = connect_pomdp.num_agents + connect_pomdp.num_leaders

current_states = POMDPs.initialstate_distribution(connect_pomdp)

for _ in  1:num_steps
    # Transition
    t_prob = transition(connect_pomdp, current_states, action_hard)
    print("Transition Probability")
    println(t_prob)
    for n = 1:num_bots
        # Sample t_prob
        relative_new_states = rand(t_prob[n], 1)
        print("relative: ")
        println(relative_new_states)
        
        # Get the reachable states
        reachable_s_bot = compute_reachable_states(current_states[n])
        # get the reachable state that matches the realization of the transition
        # distribution
        print("reachable: ")
        println(reachable_s_bot)
        current_states[n] = reachable_s_bot[relative_new_states]
        print("New state for robot ")
        print(n)
        print(" is ")
        println(current_states[n])
    end
end
