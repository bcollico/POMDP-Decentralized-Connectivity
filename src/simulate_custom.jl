using POMDPs
using POMDPPolicies
using POMDPModelTools

include("aa228_final_project.jl")
include("compute_connectivity.jl")

function our_simulate(policy, current_states, leader_action, belief_array)
    updater_ = updater(policy)

    # Get the POMDP
    pomdp = policy.pomdp
    n = pomdp.n_grid_size
    𝒮 = CartesianIndices(ones(pomdp.n_grid_size, pomdp.n_grid_size))

    # Get actions
    #actions = action(policy, current_states)
    actions = tuple()
    current_state_observation = tuple()

    # Get global observation distribution
    observation_dist = POMDPs.observation(pomdp, actions, current_states)

    num_bots = pomdp.num_leaders+pomdp.num_agents
    observed_state_i_array = []

    for i in (pomdp.num_leaders+1):num_bots
        # Initialize tuple to store current agent's observation of other agent states
        current_state_observation = tuple()

        belief_i = belief_array[i-pomdp.num_leaders]

        # Actualize the observation from the global observation distribution
        observation = rand(observation_dist)

        # Iterate through observed agents to check connectivity
        for j in 1:length(observation)
            
            # Tuple of states for agents i and j, check connectivity
            state_pair = (rand(current_states)[i], rand(current_states)[j])

            # If there is no connectivity between agents, produce observation from adjacent states
            if i != j && compute_connectivity(state_pair, pomdp) == 0
                # Compute states adjacent to Agent j
                j_reach = compute_reachable_states(state_pair[2])

                # Create Uniform Categorical Distribution over j's adjacent states
                j_dist = SparseCat(j_reach, ones(length(j_reach))/length(j_reach))

                # Actualize a state observation for the current robot
                current_state_j = rand(j_dist)
                while current_state_j ∉ 𝒮
                    # Resample if state isn't on board (e.g. (-1, 1) )
                    current_state_j = rand(j_dist)
                end
            else
                # If there is connectivity then keep the actualized observation
                current_state_j = observation[j]
            end
            # Add Agent i's observation of Agent j to the current observation tuple
            current_state_observation = (current_state_observation[:]..., current_state_j)
        end

        #println("current state belief: $(current_state_observation)")

        push!(observed_state_i_array, Deterministic(current_state_observation))
        #current_state_observation = Deterministic(current_state_observation)

        # Obtain the action for Agent i based on it's observation
        action_i = action(policy, observed_state_i_array[i-pomdp.num_leaders])[i]

        # Add Agent i's observation to the global action tuple
        actions = (actions, action_i)
    end
    actions = (leader_action, actions[2:end]...)

    for i in (pomdp.num_leaders+1):num_bots
        println("current observation: $(observed_state_i_array[i-pomdp.num_leaders])")
        belief_array[i-pomdp.num_leaders] = update(updater_, belief_array[i-pomdp.num_leaders], actions, observed_state_i_array[i-pomdp.num_leaders])
    end

    # Compute Connectivity and rewards
    s = rand(current_states)
    r = POMDPs.reward(pomdp, s, actions)
    λ = compute_connectivity(s, pomdp)

    # Transition and sample the new state
    t_prob = POMDPs.transition(pomdp, current_states, actions)
    new_states = Deterministic(rand(t_prob))

    # print("New states: ")
    # println(new_states)

    return new_states, r, λ, belief

end
