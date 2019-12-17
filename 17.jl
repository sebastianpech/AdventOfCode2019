using Revise
includet("IntComputer.jl"); using .IntComputer

parse_output(out) = transpose(reshape(out[1:end-1],findfirst(==(Int('\n')),out),:))[1:end,1:end-1]

code = intcode_from_file("17.input")
out = run!(code)
parsed = parse_output(out)

is_intersection(parsed,r,c) = parsed[r,c] && parsed[r-1,c] && parsed[r,c-1] && parsed[r+1,c] && parsed[r,c+1]
_parsed = parsed .== Int('#')
intersections = [(r,c) for (r,c) in Iterators.product(2:size(parsed,1)-1,2:size(parsed,2)-1) if is_intersection(_parsed,r,c)]

mapreduce(+,intersections) do inter
    *(inter[1]-1,inter[2]-1)
end

const Point = Tuple{Int,Int}

const NORTH = 0
const EAST  = 1
const SOUTH = 2
const WEST  = 3

const direction_mapping = Dict(
    Int('^') => NORTH,
    Int('v') => SOUTH,
    Int('<') => WEST,
    Int('>') => EAST)

const reverse_direction_mapping = Dict(
    NORTH=>Int('^'),
    SOUTH=>Int('v'),
    WEST=>Int('<'),
    EAST=>Int('>'))


const unit_vectors_direction = Dict(
    NORTH=>(-1,0),
    SOUTH=>(1,0),
    WEST =>(0,-1),
    EAST =>(0,1),
)

mutable struct Robot
    map::Matrix{Int}
    location::Point
    orientation::Int
    log::Vector{Union{Symbol,Int}}
    function Robot(map::Matrix{Int})
        location = findfirst(x->x in keys(direction_mapping),map)
        this = new(copy(map), location.I, direction_mapping[map[location]], Union{Symbol,Int}[])
        this.map[location] = Int('#')
        return this
    end
end

function turn(current_orientation::Int,dir::Int)
    orientation = ( current_orientation + dir ) % 4
    if orientation < 0
        orientation += 4
    end
    return orientation
end

function turnLeft!(r::Robot)
    push!(r.log,:L)
    r.orientation = turn(r.orientation,-1)
    nothing
end

function turnRight!(r::Robot)
    push!(r.log,:R)
    r.orientation = turn(r.orientation,1)
    nothing
end

function move!(r::Robot)
    new_location = r.location .+ unit_vectors_direction[r.orientation]
    @assert r.map[CartesianIndex(new_location)] == Int('#') "Don't jump, please"
    if length(r.log) > 0 && r.log[end] isa Int
        r.log[end] += 1
    else
        push!(r.log,1)
    end
    r.location = new_location
    nothing
end

function viz(r::Robot)
    new_map = copy(r.map)
    new_map[CartesianIndex(r.location)] = reverse_direction_mapping[r.orientation]
    for r in eachrow(new_map)
        print.(Char.(r))
        println()
    end
end

abyss_front(r::Robot) = try
    return r.map[CartesianIndex(r.location .+ unit_vectors_direction[r.orientation])] != Int('#')
catch e
    return true
end

abyss_left(r::Robot) = try
    r.map[CartesianIndex(r.location .+ unit_vectors_direction[turn(r.orientation,-1)])] != Int('#')
catch e
    return true
end

abyss_right(r::Robot) = try
    r.map[CartesianIndex(r.location .+ unit_vectors_direction[turn(r.orientation,1)])] != Int('#')
catch e
    return true
end

function visit_all!(r::Robot)
    while !(abyss_front(r) && abyss_left(r) && abyss_right(r))
        while !abyss_front(r)
            move!(r)
        end
        if abyss_left(r) && !abyss_right(robot)
            turnRight!(robot)
        elseif !abyss_left(r) && abyss_right(robot)
            turnLeft!(robot)
        end
    end
end

function counter_seq_occurrence(log,seq)
    c = 0
    for i in 1:length(log)-length(seq)
        if log[i:i+length(seq)-1] == seq
            c += 1
        end
    end
    return c
end

function analyze(log, start=Union{Symbol,Int}[], sequences=Dict{Tuple,Int}())
    from, to = extrema(filter(x->x isa Int,log))
    seq = Union{Symbol,Int}[start...,:R,0]
    for len in from:to
        seq[end] = len
        seq[end-1] = :R
        c = counter_seq_occurrence(log,seq)
        if c > 0 && 2*length(seq)-1 <= 20
            sequences[Tuple(seq)] = c*(length(seq)-1)
            analyze(log, seq, sequences)
        end
        seq[end-1] = :L
        c = counter_seq_occurrence(log,seq)
        if c > 0 && 2*length(seq)-1 <= 20
            sequences[Tuple(seq)] = c*(length(seq)-1)
            analyze(log, seq, sequences)
        end
    end
    return sequences
end

function replace_combination!(log,combination,rep)
    while true
        for i in 1:length(log)-length(combination)+1
            rng = i:i+length(combination)-1
            if all(log[rng] .== combination)
                splice!(log,rng,[rep])
                break
            end
            i == length(log)-length(combination)+1 && return nothing
        end
    end
end

function find_optimum(log,comb)
    combinations = keys(comb)
    best_val = length(log)
    best_comb = Vector{Any}(undef,3)
    for c1 in combinations
        for c2 in combinations
            c1 == c2 && continue
            for c3 in combinations
                c1 == c3 && continue
                c2 == c3 && continue
                _log = copy(log)
                replace_combination!(_log,c1,:A)
                replace_combination!(_log,c2,:B)
                replace_combination!(_log,c3,:C)
                if length(_log) < best_val
                    best_val = length(_log)
                    best_comb[1] = c1
                    best_comb[2] = c2
                    best_comb[3] = c3
                end
            end
        end
    end
    return best_comb, best_val
end

function part2(file,seq,combinations)
    code = intcode_from_file(file)
    main = Int.(first.(split(join(string.(seq),','),"")))
    push!(main,Int('\n'))
    combs = collect.(Iterators.flatten.(map(combinations) do comb
        foldr(map(comb) do c
            c isa Symbol && return Int(first(string(c)))
            if c >= 10
                c1 = c÷2
                c2 = c-c1
                return c1+48,Int(','),c2+48
            end
            return c+48
        end) do a,b
            vcat(a,Int(','),b)
        end
    end))
    push!.(combs,Ref(Int('\n')))
    code[1] = 2 # Wake up robot
    commands = vcat(
        main...,
        combs[1]...,
        combs[2]...,
        combs[3]...,
        Int('n'),Int('\n'))
    run!(code,input=commands)
end

robot = Robot(parsed)
visit_all!(robot)

sequences = analyze(robot.log)
best_comb, best_val = find_optimum(robot.log,sequences)

main_code = copy(robot.log)
replace_combination!.(Ref(main_code),best_comb,[:A,:B,:C])

out = part2("17.input", main_code, best_comb)