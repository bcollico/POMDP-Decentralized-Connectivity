using POMDPPolicies
using POMDPSimulators
using POMDPModelTools
using Distributions

include("aa228_final_project.jl")
include("plot_states.jl")

function run_custom_stepthrough(pomdp::ConnectPOMDP, policy, num_steps::Int,
    show_display::Bool)
    current_state = POMDPs.initialstate(pomdp)

    for n in 1:num_steps
        fig, _ = multiagent_grid_world_plot(p, p.obstacles_map, current_state)
        # println("Generated figure, now displaying the figure.")
        if show_display
            display(fig)
        end
        # println("Saving the figure.")
        savefig(fig, "./plots/example_simulate_grid_world-$n.png")


        # global current_state
        # Get the next action
        next_action = action(policy, current_state)
        println("Chose action: $next_action")
        # Get the transition distribution
        t_dist = POMDPs.transition(pomdp, current_state, next_action)
        # Sample from the transition distribution
        current_state = rand(t_dist)
        println("Now at $current_state")
    end
end

p = ParamsStruct()
p.n_obstacles = 6
p.obstacles_map = Map(gen_multiple_rand_obstacles(p.n_obstacles, p.n_grid_size))
connect_pomdp = ConnectPOMDP(p)
rand_policy = RandomPolicy(connect_pomdp)

num_steps = 6
run_custom_stepthrough(connect_pomdp, rand_policy, num_steps, false)
