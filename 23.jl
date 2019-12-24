using Revise
includet("IntComputer.jl"); using .IntComputer

function init_computers(file)
    code = intcode_from_file(file)
    input = [Channel{Int}(Inf) for _ in 1:50]
    output = [Channel{Int}(Inf) for _ in 1:50]
    computers = [ @async(run!(copy(code), input=input[i], output=output[i])) for i in 1:length(input)]
    return input, output, computers
end

function twice_in_row(v)
    for i in 1:length(v)-1
        v[i] == v[i+1] && return v[i]
    end
    return nothing
end

function NWcontroller(input,output, computers, use_nat=true)
    NAT_tracking = Int[]
    NAT = (X=-1, Y=-1)
    not_sending = 0
    while true
        push!.(input,Ref(-1))
        not_sending += 1
        for i in 1:length(output)
            out = output[i]
            c = computers[i]
            istaskdone(c) && continue
            isready(out) || continue
            not_sending = 0
            dst = take!(out)
            X = take!(out)
            Y = take!(out)
            if dst == 255
                NAT = (X=X, Y=Y)
                if !use_nat
                    @info "Ending ..." NAT
                    return
                end
            elseif dst <= 49
                push!(input[dst+1],X)
                push!(input[dst+1],Y)
            end
        end
        sleep(0.01)
        if not_sending > 10
            not_sending = 0
            @info "Network is idle"
            @info "Sending to 0" NAT.X NAT.Y
            push!(input[1], NAT.X)
            push!(input[1], NAT.Y)
            push!(NAT_tracking, NAT.Y)
            twice = twice_in_row(NAT_tracking)
            if twice != nothing
                @info "Found twice in a row" twice
                return
            end
        end
    end
end

# Part 01
input, output, computers = init_computers("23.input")
# Start them
push!.(input,0:49)
NWcontroller(input,output,computers, false)

# Part 02
input, output, computers = init_computers("23.input")
# Start them
push!.(input,0:49)
NWcontroller(input,output,computers)