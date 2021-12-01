using POMDPs
using POMDPPolicies
using POMDPModelTools

include("aa228_final_project.jl")
include("compute_connectivity.jl")

function our_simulate(policy, current_states, leader_action)
    # Get the POMDP
    pomdp = policy.pomdp
    n = pomdp.n_grid_size
    𝒮 = CartesianIndices(ones(pomdp.n_grid_size, pomdp.n_grid_size))

    # Get actions
    #actions = action(policy, current_states)
    actions = tuple()
    current_state_observation = tuple()
    observation_dist = POMDPs.observation(pomdp, actions, current_states)
    for i in (pomdp.num_leaders+1):(pomdp.num_leaders+pomdp.num_agents)
        current_state_observation = tuple()
        observation = rand(observation_dist)
        for j in 1:length(observation)
            state_pair = (rand(current_states)[i], rand(current_states)[j])
            # If there is no connectivity between agents, produce random observation
            if i != j && compute_connectivity(state_pair, pomdp) == 0
                j_reach = compute_reachable_states(state_pair[2])
                j_dist = SparseCat(j_reach, ones(length(j_reach))/length(j_reach))
                current_state_j = rand(j_dist)
                while current_state_j ∉ 𝒮
                    # resample if state isn't on board
                    current_state_j = rand(j_dist)
                end
                #current_state_j = CartesianIndex(Int(ceil(rand()*n)), Int(ceil(rand()*n)))

            else
                current_state_j = observation[j]
            end
            current_state_observation = (current_state_observation[:]..., current_state_j)
        end
        println("current state belief: $(current_state_observation)")
        current_state_observation = Deterministic(current_state_observation)
        action_i = action(policy, current_state_observation)[i]
        actions = (actions, action_i)
    end
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
