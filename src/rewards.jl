include("compute_connectivity.jl")

"""
    The function rewards() takes in the positions of agents and leaders 
    as an array of CartesianIndices, the obstacle positions as an array of CartesianIndices, 
    the algebraic connectivity value and a ConnectPOMDP instantiation and 
    computes the reward for being in the state s_tot. 

    It calculates the three independent rewards: reward for agent collisions, 
    reward for obstacle collision and reward for connectivity maintenance.

    It then sums them up to return the total reward of the system.
"""
function POMDPs.reward(pomdp::ConnectPOMDP, s_tot::Tuple, a::Tuple)
    num_agents = pomdp.num_agents
    num_leaders = pomdp.num_leaders
    obstacle_arr = pomdp.obstacles.obstacleLocations
    num_obstacles = length(obstacle_arr)

    alg_connect = compute_connectivity(s_tot, pomdp)

    reward_collisions = 0
    reward_obstacles = 0
    reward_connect = 0

    # compute agent collision reward
    for i in 1:num_agents+num_leaders
        for j in 1:num_agents+num_leaders
            if j!=i
                dist = maximum(abs.([s_tot[i][1]-s_tot[j][1], s_tot[i][2]-s_tot[j][2]]))
                #println("dist = $(dist)")
                if dist <= pomdp.agent_collision_buffer
                    reward_collisions += pomdp.R_a
                end
            end
        end
    end

    # compute obstacle collision reward
    for i in 1:num_agents+num_leaders
        for j in 1:num_obstacles
            dist = maximum(abs.([s_tot[i][1]-obstacle_arr[j][1], s_tot[i][2]-obstacle_arr[j][2]]))
            if dist <= pomdp.object_collision_buffer
                reward_obstacles += pomdp.R_o
            end
        end
    end

    # compute connectivity maintenance reward
    if alg_connect <= 0
        reward_connect += pomdp.R_λ
    end

    return reward_collisions + reward_obstacles + reward_connect
end
