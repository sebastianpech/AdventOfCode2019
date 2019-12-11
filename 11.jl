using Revise
includet("IntComputer.jl"); using .IntComputer

const BLACK = 0
const WHITE = 1
const LEFT  = 0
const RIGHT = 1
const NORTH = 0
const EAST  = 1
const SOUTH = 2
const WEST  = 3

const Δ = Dict(
    NORTH => (0,-1),
    EAST  =>  (1,0),
    SOUTH => (0,1),
    WEST  => (-1,0)
)

function init_robot(code)
    camera = Channel{Int}(1)
    response = Channel{Int}(1)
    robot = @async run!(code,input=camera,output=response)
    return function (current_color)
        push!(camera,current_color)
        istaskdone(robot) && return nothing
        return take!(response),take!(response)
    end
end

function paint(file,initial=BLACK)
    robot = intcode_from_file(file) |> init_robot
    locations = Dict{Tuple{Int,Int},Int}()
    current_location = (0,0)
    locations[current_location] = initial
    current_orientation = NORTH
    while true
        current_color = get(locations,current_location,BLACK)
        operation = robot(current_color)
        operation == nothing && break
        locations[current_location] = operation[1]
        Δα = operation[2] == LEFT ? -1 : 1
        current_orientation = (current_orientation + Δα)%4
        if current_orientation < 0
            current_orientation += 4
        end
        current_location = current_location .+ Δ[current_orientation]
    end
    return locations
end

locs = paint("11.input")
length(locs)

locs = paint("11.input",WHITE)

function render(locations)
    x = [c[1] for c in keys(locations)]
    y = [c[2] for c in keys(locations)]
    current_row = coords[1][2]
    for y in minimum(y):maximum(y)
        for x in minimum(x):maximum(x)
            if (x,y) in keys(locations)
                locations[(x,y)] == WHITE && print("█")
                locations[(x,y)] == BLACK && print(" ")
            else
                print(" ")
            end
        end
        println()
    end
end

render(locs)

using JuliaKara

function paint(kara,file)
    robot = intcode_from_file(file) |> init_robot
    while true
        current_color = onLeaf(kara) ? WHITE : BLACK
        operation = robot(current_color)
        operation == nothing && break
        if operation[1] == WHITE && !onLeaf(kara)
            putLeaf(kara)
        elseif operation[1] == BLACK && onLeaf(kara)
            removeLeaf(kara)
        end
        operation[2] == LEFT  && turnLeft(kara)
        operation[2] == RIGHT && turnRight(kara)
        move(kara)
    end
end

@World (50,15)
paint(kara,"11.input")
reset!(world)
