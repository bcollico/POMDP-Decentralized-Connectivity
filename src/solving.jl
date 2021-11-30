# This script is to solve the POMDP using tools in POMDPs.jl
using POMDPPolicies
# using QMDP, DiscreteValueIteration
using FIB

println("Adding dependencies")
# Include all the dependencies
include("aa228_final_project.jl")

# Initialize the default parameters and make a POMDP from it
println("Instantiating the POMDP")
p = ParamsStruct()
connect_pomdp = ConnectPOMDP(p)

# initialize the solver
# key-word args are the maximum number of iterations the solver will run for, and the Bellman tolerance
println("Instantiating the solver")
# solver = QMDPSolver(SparseValueIterationSolver(max_iterations=20, verbose=true))
solver = FIBSolver()

# run the solver
println("Solving the POMDP")
policy = solve(solver, connect_pomdp)
