function parse_input(inp)
    reg = r"<x=([-]*\d+), y=([-]*\d+), z=([-]*\d+)>"
    lines = split(strip(inp), "\n")
    v = map(match.(Ref(reg), lines)) do m
        parse.(Int, [m[1], m[2], m[3]])
    end
end

function simulate_motion(moons; v = map(moons) do m
        zeros(Int, 3)
end,steps = 10)
    N = length(moons)
    for _ in 1:steps
        for i in 1:N
            for j in 1:N
                i == j && continue
                @. v[i] += -(moons[i] .> moons[j]) + (moons[i] .< moons[j])
            end
        end
        moons .+= v
    end
    return moons, v
end

using LinearAlgebra

function total_energy(moons, v)
    pot = map(moons) do m
        sum(abs.(m))
    end
    kin = map(v) do m
        sum(abs.(m))
    end
    pot ⋅ kin
end

function history(moons,N)
    v = map(moons) do m
        zeros(Int, 3)
    end
    hist = Vector{Vector{Vector{Int}}}(undef,N)
    hist[1] = copy(moons)
    for i in 2:N
        simulate_motion(moons, v = v, steps = 1)
        hist[i] = copy(moons)
    end
    hist
end

function analyze(hist,moon,axis)
    y = [h[moon][axis] for h in hist]
    N = length(y)
    for n in 1:N÷2
        recurring_pattern = @view y[1:n]
        is_recurring_pattern(y,recurring_pattern) && return recurring_pattern
    end
    error("No pattern found for moon=$moon, axis=$axis")
end

function is_recurring_pattern(y, pattern)
    N = length(y)
    n = length(pattern)
    for i in 1:(N÷n)-1
        any(x->x[1]!==x[2],zip(view(y,n*i+1:n*(i+1)),pattern)) && return false
    end
    return true
end

example01 = """
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
"""

my_input = """<x=-3, y=10, z=-1>
<x=-12, y=-10, z=-5>
<x=-9, y=0, z=10>
<x=7, y=-5, z=-3>
"""

example02 = """
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
"""

moons = parse_input(my_input)
hist = history(moons,1000000)

patterns = [
    [length(analyze(hist,moon,axis)) for axis in 1:3]
    for moon in 1:length(moons) ]

reduce(lcm,(reduce(vcat,patterns)))