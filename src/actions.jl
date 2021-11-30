using POMDPs

include("./params.jl")

"""
    POMDPs.actions(pomdp::ConnectPOMDP) 

The ConnectPOMDP is specified over an n-by-n grid world with m number of 
decision-making agents. Each agent has an action space with cardinality of 9 --
8 directions to move and 1 option to remain stationary. The action space of the
overall problem has cardinality m-by-9

### Inputs:
- pomdp     --The ConnectPOMDP instance

### Outputs:
- 𝒜        -- The full action space
"""
function POMDPs.actions(pomdp::ConnectPOMDP) 
    
    # The Grid Size (i.e., n_grid_size x n_grid_size)
    n_grid_size = pomdp.n_grid_size

    # Total Number of Decision-Raking Robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    # Actions for a Single Agent
    a = [:east, :northeast, :north, :northwest,
         :west, :southwest, :south, :southeast, :stay]

    return collect(Base.product([a for _ in 1:num_bots]...))
end

"""
    POMDPs.actionindex(pomdp::ConnectPOMDP, a::Tuple)

Determine the linear index of the actions taken by each agent.

### Inputs:
- pomdp     -- The ConnectPOMDP instance

### Outputs:
- a_ind     -- Array of linear indices for each agents' action
"""
function POMDPs.actionindex(pomdp::ConnectPOMDP, a::Tuple)
    # Total Number of Decision-Raking Robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    a_ind = action_index_list(pomdp, a)

    # Outer dimension is (n x n)^(num_bots)
    outer_bot_num_dimension = Tuple([9 for bot in 1:num_bots])

    return LinearIndices(outer_bot_num_dimension)[a_ind...]
end


function action_index_list(pomdp::ConnectPOMDP, a::Tuple)
    # The Grid Size (i.e., n_grid_size x n_grid_size)
    n_grid_size = pomdp.n_grid_size

    # Total Number of Decision-Raking Robots
    num_bots = pomdp.num_agents + pomdp.num_leaders

    a_ind = zeros(Int,num_bots)
    for k = 1:num_bots
        if a[k] == :east;          a_ind[k] = 1
        elseif a[k] == :northeast; a_ind[k] = 2
        elseif a[k] == :north;     a_ind[k] = 3
        elseif a[k] == :northwest; a_ind[k] = 4
        elseif a[k] == :west;      a_ind[k] = 5
        elseif a[k] == :southwest; a_ind[k] = 6
        elseif a[k] == :south;     a_ind[k] = 7
        elseif a[k] == :southeast; a_ind[k] = 8
        elseif a[k] == :stay;      a_ind[k] = 9
        end
    end

    if any(a_ind==0)
        warn("0 detected in action indices: Check actions.jl")
    end

    return a_ind
end
