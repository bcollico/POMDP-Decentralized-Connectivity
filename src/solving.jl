# This script is to solve the POMDP using tools in POMDPs.jl
using POMDPPolicies
using QMDP, DiscreteValueIteration
# using FIB
using FileIO, JLD2
using POMDPSimulators

println("Adding dependencies")
# Include all the dependencies
include("aa228_final_project.jl")

# USER DEFINED
run_solver_from_scratch = true

# Initialize the default parameters and make a POMDP from it
println("Instantiating the POMDP")
p = ParamsStruct()
p.n_grid_size = 50
p.n_obstacles = 100

ob_arr = [
    CartesianIndex(18, 18),
CartesianIndex(24, 31),
CartesianIndex(8, 35),
CartesianIndex(50, 22),
CartesianIndex(46, 30),
CartesianIndex(9, 27),
CartesianIndex(14, 46),
CartesianIndex(44, 31),
CartesianIndex(46, 38),
CartesianIndex(26, 38),
CartesianIndex(38, 33),
CartesianIndex(3, 18),
CartesianIndex(11, 12),
CartesianIndex(1, 30),
CartesianIndex(32, 26),
CartesianIndex(6, 36),
CartesianIndex(13, 37),
CartesianIndex(44, 50),
CartesianIndex(38, 12),
CartesianIndex(39, 9),
CartesianIndex(32, 13),
CartesianIndex(39, 25),
CartesianIndex(39, 49),
CartesianIndex(39, 43),
CartesianIndex(2, 10),
CartesianIndex(11, 3),
CartesianIndex(24, 5),
CartesianIndex(43, 3),
CartesianIndex(4, 28),
CartesianIndex(3, 35),
CartesianIndex(44, 27),
CartesianIndex(12, 6),
CartesianIndex(46, 33),
CartesianIndex(29, 6),
CartesianIndex(43, 14),
CartesianIndex(1, 4),
CartesianIndex(49, 11),
CartesianIndex(43, 11),
CartesianIndex(14, 21),
CartesianIndex(45, 26),
CartesianIndex(7, 39),
CartesianIndex(7, 48),
CartesianIndex(47, 15),
CartesianIndex(46, 35),
CartesianIndex(21, 35),
CartesianIndex(40, 25),
CartesianIndex(23, 2),
CartesianIndex(18, 2),
CartesianIndex(12, 34),
CartesianIndex(4, 14),
CartesianIndex(42, 28),
CartesianIndex(37, 2),
CartesianIndex(28, 5),
CartesianIndex(16, 48),
CartesianIndex(45, 39),
CartesianIndex(42, 13),
CartesianIndex(32, 45),
CartesianIndex(49, 32),
CartesianIndex(26, 37),
CartesianIndex(48, 39),
CartesianIndex(40, 22),
CartesianIndex(22, 32),
CartesianIndex(30, 45),
CartesianIndex(15, 23),
CartesianIndex(34, 44),
CartesianIndex(47, 32),
CartesianIndex(37, 10),
CartesianIndex(9, 26),
CartesianIndex(44, 36),
CartesianIndex(18, 35),
CartesianIndex(17, 17),
CartesianIndex(9, 38),
CartesianIndex(34, 46),
CartesianIndex(1, 38),
CartesianIndex(9, 8),
CartesianIndex(17, 31),
CartesianIndex(30, 34),
CartesianIndex(20, 20),
CartesianIndex(14, 6),
CartesianIndex(35, 25),
CartesianIndex(40, 12),
CartesianIndex(46, 36),
CartesianIndex(48, 32),
CartesianIndex(48, 13),
CartesianIndex(14, 36),
CartesianIndex(50, 47),
CartesianIndex(38, 14),
CartesianIndex(19, 25),
CartesianIndex(5, 31),
CartesianIndex(39, 8),
CartesianIndex(35, 45),
CartesianIndex(21, 47),
CartesianIndex(50, 21),
CartesianIndex(22, 28),
CartesianIndex(47, 36),
CartesianIndex(42, 23),
CartesianIndex(30, 35),
CartesianIndex(49, 9),
CartesianIndex(39, 5),
CartesianIndex(9, 9)
]

p.obstacles_map = Map(ob_arr)
p.init_states = (CartesianIndex(35, 35), CartesianIndex(25, 15))

connect_pomdp = ConnectPOMDP(p)

# initialize the solver
if run_solver_from_scratch
    # key-word args are the maximum number of iterations the solver will run for, and the Bellman tolerance
    println("Instantiating the solver")
    # solver = QMDPSolver(SparseValueIterationSolver(max_iterations=20, verbose=true))
    # solver = FIBSolver(verbose=true)
    solver = QMDPSolver(max_iterations=20, belres=1e-3, verbose=true)

    # run the solver
    println("Solving the POMDP")
    policy = solve(solver, connect_pomdp)

    # save the policy
    save("qmdp_policy-1-1-100.jld2", "policy", policy)
else
    # loading policy
    println("loading policy")
    policy = load("qmdp_policy-1-1-100.jld2", "policy")
end


# Now try to stepthrough
for (s, a, r) in stepthrough(connect_pomdp, policy, "s,a,r", max_steps=10)
    @show s
    @show a
    @show r
    println()
end
