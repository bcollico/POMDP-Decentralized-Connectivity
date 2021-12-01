using POMDPs
using POMDPPolicies

include("aa228_final_project.jl")
include("compute_connectivity.jl")

function our_simulate(policy, current_states, leader_action)
    # Get the POMDP
    pomdp = policy.pomdp

    # Get actions
    actions = action(policy, current_states)
    actions = (leader_action, actions[2:end]...)

    # Compute Connectivity and rewards
    s = rand(current_states)
    r = POMDPs.reward(pomdp, s, actions)
    λ = compute_connectivity(s, pomdp)

    # Transition and sample the new state
    t_prob = POMDPs.transition(pomdp, current_states, actions)
    new_states = Deterministic(rand(t_prob))

    # print("New states: ")
    # println(new_states)

    return new_states, r, λ

end
