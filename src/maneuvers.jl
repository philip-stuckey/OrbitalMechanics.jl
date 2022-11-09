struct Maneuver{D,T,U}
    done::D
    throttle::T
    declination::U
end
    
function Maneuver(;done, throttle::T=0.0, declination::T=0.0) where T <: Real
    return Maneuver(done, (_...)-> throttle, (_...)-> declination)
end

function runManeuver!(ship, maneuver::Maneuver, parameters; path=nothing)
    body=parameters.body
    Δt=parameters.time_step
    snapshot_rate = parameters.snapshot_rate
	
    loops_since_last_snapshot=0
    for t in 0:Δt:parameters.time_limit
        maneuver.done(ship) && break
        delta_v(ship) <= 0 && break

        ship.throttle=maneuver.throttle(ship,t)
        ship.declination = maneuver.declination(ship,t)
        Simulate!(ship, body; Δt)
        loops_since_last_snapshot += 1

        if path !== nothing && loops_since_last_snapshot > 1/(snapshot_rate*Δt)
            push!(path, deepcopy(ship))
            loops_since_last_snapshot=0
        end
    end
    path === nothing || push!(path, deepcopy(ship))
    return path
end
