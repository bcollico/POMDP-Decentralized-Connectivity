# using Combinatorics

action_space = [:east, :northeast, :north, :northwest,
:west, :southwest, :south, :southeast, :stay]
num_agents = 4

# p = combinations(action_space, num_agents)
# p = multiset_permutations(action_space, num_agents)
# collect(p)

itp = Base.product([action_space for _ in 1:num_agents]...)
println(collect(itp))
rand(collect(itp))
