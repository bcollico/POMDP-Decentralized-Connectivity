using POMDPs
using POMDPPolicies
using POMDPModelTools
using BeliefUpdaters

include("aa228_final_project.jl")
include("compute_connectivity.jl")


function get_action_num(a)
    if a == :east;          return  1
    elseif a == :northeast; return  2
    elseif a == :north;     return  3
    elseif a == :northwest; return  4
    elseif a == :west;      return  5
    elseif a == :southwest; return  6
    elseif a == :south;     return  7
    elseif a == :southeast; return  8
    elseif a == :stay;      return  9
    end
end

function compute_contingent_policy(policy, leader_action, belief)
    # Get the 1D index of the leader action
    action_ind = get_action_num(leader_action)
    # Get number of alphas
    num_alphas = length(policy.alphas)
    # Calculate the index of the best action contingent on the leader_action
    best_aind = action_ind + 9 * (argmax([policy.alphas[aind]'belief.b for aind in action_ind:9:num_alphas]) - 1)
    # Return the action
    return ordered_actions(policy.pomdp)[best_aind]
end

function agent_belief(pomdp, b)
    bi = argmax(b.b)
    return ordered_states(pomdp)[bi]
end

function our_simulate(policy, updater_, current_states, leader_action, belief_array)
    pomdp = policy.pomdp

    # num_bots = pomdp.num_leaders+pomdp.num_agents
    belief_state_i_array = []

    actions_arr = [leader_action]
    actions_believed = []

    for i in 1:pomdp.num_agents
        belief_i = belief_array[i]

        # (1) compute actions contingent on the leader action
        actions = compute_contingent_policy(policy, leader_action, belief_i)
        println("actions = $(actions)")

        push!(actions_arr, actions[i + pomdp.num_leaders])
        push!(actions_believed, actions)
    end

    joint_actions = Tuple(actions_arr)

    # (2) transition the true state to s'
    println("Computing T($(current_states), $(joint_actions))")
    td = POMDPs.transition(pomdp, current_states, joint_actions)
    # display(td)
    sp = rand(td)
    println("transitioned to $(sp)")

    # (3) realize an observation given s' and actions
    # Would use believed actions in true decentralized
    o = rand(POMDPs.observation(pomdp, joint_actions, sp))

    for i in 1:pomdp.num_agents
        # println("observed $(o)")

        # (4) update the belief with our prior, the actions, and the observations
        ow = obs_weight(pomdp, current_states, actions_believed[i], sp, o)
        # println("Observation weight = $(ow)")

        # println("Agent belief is $(agent_belief(pomdp, belief_array[i]))")

        # error("Stop")

        # bp = initialize_belief(updater_, Deterministic(sp)) 
        bp = update(updater_, belief_array[i], actions_believed[i], o)
        println("Agent belief is $(agent_belief(pomdp, bp))")
        push!(belief_state_i_array, bp)
    end

    # (5) compute the rewards
    r = POMDPs.reward(pomdp, sp, joint_actions)
    λ = compute_connectivity(sp, pomdp)

    # (6) return the updated belief and the true new state
    return belief_state_i_array, sp, r, λ
    
end


function our_simulate_random(policy, pomdp, updater_, current_states, leader_action, belief_array)
    # pomdp = policy.pomdp

    # num_bots = pomdp.num_leaders+pomdp.num_agents
    belief_state_i_array = []

    actions_arr = [leader_action]
    actions_believed = []

    for i in 1:pomdp.num_agents
        belief_i = belief_array[i]

        # (1) compute actions contingent on the leader action
        actions = action(policy, belief_i) # compute_contingent_policy(policy, leader_action, belief_i)
        println("actions = $(actions)")

        push!(actions_arr, actions[i + pomdp.num_leaders])
        push!(actions_believed, actions)
    end

    joint_actions = Tuple(actions_arr)

    # (2) transition the true state to s'
    println("Computing T($(current_states), $(joint_actions))")
    td = POMDPs.transition(pomdp, current_states, joint_actions)
    # display(td)
    sp = rand(td)
    println("transitioned to $(sp)")

    # (3) realize an observation given s' and actions
    o = rand(POMDPs.observation(pomdp, joint_actions, sp))

    for i in 1:pomdp.num_agents
        # println("observed $(o)")

        # (4) update the belief with our prior, the actions, and the observations
        ow = obs_weight(pomdp, current_states, actions_believed[i], sp, o)
        # println("Observation weight = $(ow)")

        # println("Agent belief is $(agent_belief(pomdp, belief_array[i]))")

        # error("Stop")

        bp = initialize_belief(updater_, Deterministic(sp)) 
        # bp = update(updater_, belief_array[i], actions_believed[i], o)
        println("Agent belief is $(agent_belief(pomdp, bp))")
        push!(belief_state_i_array, bp)
    end

    # (5) compute the rewards
    r = POMDPs.reward(pomdp, sp, joint_actions)
    λ = compute_connectivity(sp, pomdp)

    # (6) return the updated belief and the true new state
    return belief_state_i_array, sp, r, λ
    
end

# function our_simulate(policy, current_states, past_actions, belief_array)
#     updater_ = updater(policy)

#     # Get the POMDP
#     pomdp = policy.pomdp
#     n = pomdp.n_grid_size
#     𝒮 = CartesianIndices(ones(pomdp.n_grid_size, pomdp.n_grid_size))

#     # Initialize actions
#     leader_action = past_actions[1]
#     actions = [leader_action]

#     # Get global observation distribution
#     observation_dist = POMDPs.observation(pomdp, past_actions, current_states)

#     num_bots = pomdp.num_leaders+pomdp.num_agents
#     belief_state_i_array = []

#     for i in (pomdp.num_leaders+1):num_bots
#         # belief_i = belief_array[i-pomdp.num_leaders]
#         println()
#         println("Obs_dist = $(observation_dist)")

#         # Actualize the observation from the global observation distribution
#         observation = rand(observation_dist)

#         println("obs = $(observation)")

#         # # Iterate through observed agents to check connectivity
#         # for j in 1:length(observation)
            
#         #     # Tuple of states for agents i and j, check connectivity
#         #     state_pair = (rand(current_states)[i], rand(current_states)[j])

#         #     # If there is no connectivity between agents, produce observation from adjacent states
#         #     if i != j && compute_connectivity(state_pair, pomdp) == 0
#         #         println("not connected")
#         #         # Compute states adjacent to Agent j
#         #         j_reach = compute_reachable_states(state_pair[2])

#         #         # Create Uniform Categorical Distribution over j's adjacent states
#         #         j_dist = SparseCat(j_reach, ones(length(j_reach))/length(j_reach))

#         #         # Actualize a state observation for the current robot
#         #         current_state_j = rand(j_dist)
#         #         while current_state_j ∉ 𝒮
#         #             # Resample if state isn't on board (e.g. (-1, 1) )
#         #             current_state_j = rand(j_dist)
#         #         end
#         #     else
#         #         # If there is connectivity then keep the actualized observation
#         #         current_state_j = observation[j]
#         #     end
#         #     # Add Agent i's observation of Agent j to the current observation tuple
#         #     current_state_observation = (current_state_observation[:]..., current_state_j)
#         #     println("Current state observation = $(current_state_observation)")
#         # end

#         # Get the current observation
#         current_state_observation = observation
#         # push!(observed_state_i_array, current_state_observation)

#         # Update the belief
#         current_belief = update(updater_, belief_array[i-pomdp.num_leaders], past_actions, current_state_observation)
#         # Push the belief
#         push!(belief_state_i_array, current_belief)

#         # Obtain the action for Agent i based on it's belief
#         action_i = action(policy, current_belief)[i]
#         println("Chose action $(action_i)")

#         # Add Agent i's observation to the global action tuple
#         push!(actions, action_i)
#     end
#     actions = Tuple(actions)

#     # println("Getting ready for update")
#     # println("belief_array = $(belief_array[1].b)")
#     # println("actions = $(actions)")
#     # println("observed_state_i_array = $(observed_state_i_array)")
#     # println("updater_ = $(updater_)")

#     # # update(updater_, belief_array[2], actions, observed_state_i_array[2]])
#     # b = update(updater_, belief_array[1], actions, observed_state_i_array[1])
#     # println("update = $b")

#     # for i in (pomdp.num_leaders+1):num_bots
#     #     println("current observation: $(observed_state_i_array[i-pomdp.num_leaders])")
#     #     # belief_array[i-pomdp.num_leaders] = update(updater_, belief_array[i-pomdp.num_leaders], actions, observed_state_i_array[i-pomdp.num_leaders])
#     # end

#     # Compute Connectivity and rewards
#     s = rand(current_states)
#     r = POMDPs.reward(pomdp, s, actions)
#     λ = compute_connectivity(s, pomdp)

#     # Transition and sample the new state
#     t_prob = POMDPs.transition(pomdp, current_states, actions)
#     new_states = Deterministic(rand(t_prob))

#     # print("New states: ")
#     # println(new_states)

#     return new_states, r, λ, belief_array

# end
