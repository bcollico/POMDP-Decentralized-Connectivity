using POMDPs
# using POMDPModelTools

include("params.jl")

"""


For now, we assume a deterministic initialstate_distribution.
"""
function POMDPs.initialstate_distribution(pomdp::ConnectPOMDP)
    
    # init_state_dist = []

    # for init_state in pomdp.init_states
    #     push!(init_state_dist, Deterministic(init_state))
    # end
    print("Initial State Type: ")
    println(typeof(pomdp.init_states))
    println(pomdp.init_states)
    return pomdp.init_states

end
