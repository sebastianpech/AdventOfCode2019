using Revise
includet("IntComputer.jl"); using .IntComputer

const NORTH = 1
const SOUTH = 2
const WEST  = 3
const EAST  = 4

opposite(direction::Int) = opposite(Val(direction))
opposite(::Val{NORTH}) = SOUTH
opposite(::Val{SOUTH}) = NORTH
opposite(::Val{EAST}) = WEST
opposite(::Val{WEST}) = EAST

const HITWALL = 0
const SUCCESS = 1
const FOUND = 2
const WALL  = 0
const FLOOR = 1
const OXYGEN = 2

const Δloc = Dict(
    NORTH => (0,-1),
    SOUTH => (0, 1),
    WEST  => (-1,0),
    EAST  => ( 1,0)
)

mutable struct Robot
    program
    input::Channel{Int}
    output::Channel{Int}
    map::Dict{Tuple{Int,Int},Int}
    location::Tuple{Int,Int}
    function Robot(code::Vector{Int})
        self = new()
        self.input = Channel{Int}()
        self.output = Channel{Int}()
        self.program = @async run!(code, input=self.input, output=self.output)
        self.location = (0,0)
        self.map = Dict(self.location=>FLOOR)
        self
    end
end
Robot(file::String) = Robot(intcode_from_file(file))

function move!(r::Robot, dir)
    istaskdone(r.program) && return nothing
    push!(r.input,dir)
    result = take!(r.output)
    trial_location = r.location .+ Δloc[dir]
    if result == HITWALL
        r.map[trial_location] = WALL
    elseif result == SUCCESS
        r.map[trial_location] = FLOOR
        r.location = trial_location
    else
        r.map[trial_location] = OXYGEN
        r.location = trial_location
    end
    return result
end


function scan_area(r,counter=0,distance_to=Dict((0,0)=>0))
    for direction in (NORTH, EAST, SOUTH, WEST)
        trial_location = r.location .+ Δloc[direction]
        trial_location in keys(r.map) && continue
        res = move!(r,direction)
        if res == SUCCESS
            distance_to[r.location] = counter+1
            scan_area(r,counter+1,distance_to)
            move!(r,opposite(direction))
        elseif res == FOUND
            distance_to[r.location] = counter+1
            move!(r,opposite(direction))
            return
        end
    end
    return r, distance_to
end

r = Robot("15.input")
r, distance_to = scan_area(r)

# Part 1
oxy_loc = collect(keys(r.map))[findfirst(x->x==OXYGEN,collect(values(r.map)))]
distance_to[oxy_loc]

# Part 2

function remove_adjacent(locations,loc,counter=0, counted=[])
    for direction in (NORTH, EAST, SOUTH, WEST)
        trial_location = loc .+ Δloc[direction]
        if trial_location in locations
            push!(counted,counter+1)
            delete!(locations,trial_location)
            remove_adjacent(locations,trial_location,counter+1,counted)
        end
    end
    return counted
end

locations = Set([p[1] for p in r.map if p[2] == FLOOR])
c = remove_adjacent(locations,oxy_loc)
maximum(c)
