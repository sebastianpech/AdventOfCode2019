using Revise
includet("IntComputer.jl"); using .IntComputer

const EMPTY = 0
const WALL = 1
const BLOCK = 2
const PADDLE = 3
const BALL = 4

const LEFT = -1
const RIGHT = 1
const NEUTRAL = 0

function example01(file)
    world = Dict{Tuple{Int,Int},Int}()
    code = intcode_from_file(file)
    output = run!(code)
    for (x, y, id) in eachcol(reshape(output, 3, :))
        world[(x, y)] = id
    end
    world
end

count(values(example01("13.input")) .== BLOCK)

using Makie

function init_arcade(file)
    code = intcode_from_file(file)
    joystick = Channel{Int}(Inf)
    response = Channel{Int}(Inf)
    code[1] = 2 # Insert 2 quarters to start the game
    arcade = @async run!(code, input = joystick, output = response)
    wait(response)
    result = Int[]
    while isready(response)
        push!(result, take!(response))
    end
    return function (input)
        istaskdone(arcade) && return nothing
        push!(joystick, input)
        result = Int[]
        wait(response)
        while isready(response)
            push!(result, take!(response))
        end
        return result
    end, result
end

function draw!(world, changes)
    for (x, y, id) in eachcol(reshape(changes, 3, :))
        world[(x, -y)] = id
    end
    world
end

function viz(sc, world)
    themes = Dict(WALL => Theme(marker = :rect, color = :white),
        BLOCK => Theme(marker = :rect, color = :green),
        PADDLE => Theme(marker = :hline, color = :white),
        BALL => Theme(marker = :circle, color = :red))
    sc.plots = AbstractPlot[]
    nodes = Any[]
    for obj in [WALL, BLOCK, PADDLE, BALL]
        n = Node(Point2f0[p[1] for p in world if p[2] == obj])
        push!(nodes, n)
        scatter!(sc, themes[obj], n, markersize = 1)
    end
    score = Node(string(first([p[2] for p in world if p[1] == (-1, 0)])))
    push!(nodes, score)
    text!(sc, score, position = (0, 0), color = :red, align = (:left, :top), textsize = 1.5)
    nodes
end

function update(nodes, world)
    for obj in [WALL, BLOCK, PADDLE, BALL]
        nodes[obj][] = Point2f0[p[1] for p in world if p[2] == obj]
    end
    score = first([p[2] for p in world if p[1] == (-1, 0)])
    nodes[end][] = string(score)
    nothing
end

function example02(file)
    world = Dict{Tuple{Int,Int},Int}()
    joystick, res = init_arcade(file)
    sc = Scene(show_axis = false, backgroundcolor = :black)
    draw!(world, res)
    nodes = viz(sc, world)
    display(sc)
    while true
        x_ball = [p[1] for p in world if p[2] == BALL][1][1]
        x_paddle = [p[1] for p in world if p[2] == PADDLE][1][1]
        if x_ball < x_paddle
            res = joystick(LEFT)
        elseif x_ball > x_paddle
            res = joystick(RIGHT)
        else
            res = joystick(NEUTRAL)
        end
        res == nothing && return
        draw!(world, res)
        update(nodes, world)
    end
end

example02("13.input")