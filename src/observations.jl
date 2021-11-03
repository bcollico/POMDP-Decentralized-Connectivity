using POMDPs

include("./params.jl")


"""

Since the observations are composed of the states + gaussian noise, the
observation space much be continuous. 

TODO: Represent the observation space continuously or as a dense discretized space
"""
function POMDPs.observations(pomdp::ConnectPOMDP)
    
end

"""

Return the distribution over each state observation as a multivariate Gaussian
distribution with mean μ = s and covariance Σ = diag([σ, ... , σ])

The underlying assumption is that the measurement noise is zero-mean, Gaussian,
and un-correlated between time instances.
"""
function POMDPs.observation(pomdp::ConnectPOMDP, a::Array{Symbol}, s::Array{CartesianIndex{2},1})
    σ = pomdp.σ_obs

    meas_cov = diagm(σ.*ones(2)) # Noise covariance for multivariate gaussian
    o = []
    for k = 1:length(s)
        push!(o, MvNormal([s[k][1], s[k][2]], meas_cov))
    end

    return o
end
