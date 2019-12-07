module IntComputer

export run!, intcode_from_file

using OffsetArrays

function param(intcode,modes::Vector,p,n)
    mode = length(modes) >= n ? modes[n] : 0
    if mode == 0
        return intcode[intcode[p+n]]
    else
        return intcode[p+n]
    end
end

function get_modes(intcode,p) 
    dig = digits(intcode[p])
    length(dig) > 2 && return dig[3:end]
    return Int[]
end

function execute!(::Val{1}, intcode, p, modes, input, output)
    intcode[intcode[p+3]] = param(intcode,modes,p,2) +
                            param(intcode,modes,p,1)
    return 4
end

function execute!(::Val{2}, intcode, p, modes, input, output)
    intcode[intcode[p+3]] = param(intcode,modes,p,2) *
                            param(intcode,modes,p,1)
    return 4
end

function execute!(::Val{3}, intcode, p, modes, input, output)
    val = popfirst!(input)
    intcode[intcode[p+1]] = val
    return 2
end

function execute!(::Val{4}, intcode, p, modes, input, output)
    push!(output, param(intcode,modes,p,1))
    return 2
end

function execute!(::Val{5}, intcode, p, modes, input, output)
    if param(intcode,modes,p,1) != 0
        return param(intcode,modes,p,2) - p
    end
    return 3
end

function execute!(::Val{6}, intcode, p, modes, input, output)
    if param(intcode,modes,p,1) == 0
        return param(intcode,modes,p,2) - p
    end
    return 3
end

function execute!(::Val{7}, intcode, p, modes, input, output)
    if param(intcode,modes,p,1) < param(intcode,modes,p,2)
        intcode[intcode[p+3]] = 1
    else
        intcode[intcode[p+3]] = 0
    end
    return 4
end

function execute!(::Val{8}, intcode, p, modes, input, output)
    if param(intcode,modes,p,1) == param(intcode,modes,p,2)
        intcode[intcode[p+3]] = 1
    else
        intcode[intcode[p+3]] = 0
    end
    return 4
end

function run!(intcode_input::Vector{Int}; input=Int[], output=Int[])
    intcode = OffsetVector(intcode_input,0:length(intcode_input)-1)
    p = 0
    while true
        intcode[p] == 99 && break
        # Get's the op no matter if in param or positional
        op = intcode[p] % 10
        modes = get_modes(intcode,p)
        p += execute!(Val(op), intcode, p, modes, input, output)
    end
    # Update input incode back
    for i in 1:length(intcode_input)
        intcode_input[i] == intcode[i-1]
    end
    return output
end

intcode_from_file(path) = parse.(Int,split(strip(read(path,String)),","))
end