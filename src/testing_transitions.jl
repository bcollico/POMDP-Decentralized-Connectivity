include("./params.jl")
include("./transitions.jl")

p = ParamsStruct()
pomdp = ConnectPOMDP(p)

s = (CartesianIndex(2,2), CartesianIndex(8,8))
a = (:east, :west)

T_dist = POMDPs.transition(pomdp, s, a)