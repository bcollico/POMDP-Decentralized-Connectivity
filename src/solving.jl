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
connect_pomdp = ConnectPOMDP(p)

# initialize the solver
if run_solver_from_scratch
    # key-word args are the maximum number of iterations the solver will run for, and the Bellman tolerance
    println("Instantiating the solver")
    solver = QMDPSolver(SparseValueIterationSolver(max_iterations=20, verbose=true))
    # solver = FIBSolver(verbose=true)

    # run the solver
    println("Solving the POMDP")
    policy_time_info = @timed policy = solve(solver, connect_pomdp)

    # save the policy
    save("qmdp_policy.jld2", "policy.jl", policy)
else
    # loading policy
    println("loading policy")
    policy = load("qmdp_policy.jld2", "policy")
end
println("Policy Learning Time: $(policy_time_info[2]) seconds")

# Now try to stepthrough
for (s, a, r) in stepthrough(connect_pomdp, policy, "s,a,r", max_steps=10)
    @show s
    @show a
    @show r
    println()
end
