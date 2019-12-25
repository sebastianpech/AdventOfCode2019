using Revise
using Combinatorics
includet("IntComputer.jl"); using .IntComputer

function init_game(file)
    code = intcode_from_file(file)
    input = Channel{Int}(Inf)
    output = Channel{Int}(Inf)
    computer = @async run!(copy(code), input=input, output=output)
    return (input=input, output=output)
end

function run_TUI(game)
    @async while true
        print.(Char.(take!(game.output)))
    end
    history = String[]
    try
        while true
            read_input = readline()
            push!(history, read_input)
            send_cmd(game,read_input)
        end
    catch e
        @show e
    finally
        return history
    end
end

function send_cmd(game, cmd, retrieve_output=false)
    command = [Int(c) for c in cmd]
    push!(command,Int('\n'))
    push!.(Ref(game.input),command)
    if retrieve_output
        output = Int[]
        wait(game.output)
        while isready(game.output)
            push!(output, take!(game.output))
        end
        return join(Char.(output))
    end
end

game = init_game("25.input")
history = run_TUI(game)

collect_all_items = [
 "north", "take mug", "north", "take food ration", "south", "east", "north", "east", "take semiconductor", "west", "south", "west", "south", "east", "take ornament", "north",
 "take coin", "east", "take mutex", "west", "south", "east", "take candy cane", "west", "west", "south", "east", "take mouse", "south", "west",
]

send_cmd.(Ref(game),collect_all_items, Ref(true))

function bruteforce_detector(game)
    all_stuff = map(filter(x->startswith(x,"-"),split(send_cmd(game,"inv",true),"\n"))) do inv
        inv[3:end]
    end
    function drop_all()
        for item in all_stuff
            send_cmd(game,"drop $item",true)
        end
    end
    function take(items)
        for item in items
            send_cmd(game,"take $item",true)
        end
    end
    for n in 1:length(all_stuff)
        for comb in combinations(all_stuff,n)
            drop_all(); take(comb)
            res = send_cmd(game,"west",true)
            if !(occursin("Alert!",res))
                println(res)
                return nothing
            end
        end
    end
end

bruteforce_detector(game)

