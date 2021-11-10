include("./params.jl")
include("./transitions.jl")
include("./observations.jl")

p = ParamsStruct()
pomdp = ConnectPOMDP(p)

s = (CartesianIndex(2,2), CartesianIndex(8,8))
a = (:east, :west)

O_dist = POMDPs.observation(pomdp, a, s)
