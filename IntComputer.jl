module IntComputer

export run!, intcode_from_file

using OffsetArrays

function param(intcode,modes::Vector{T},p, n, relative_base) where T
    mode = length(modes) >= n ? modes[n] : 0
    if mode == 0
        pos = intcode[p+n]
    elseif mode == 1
        pos = p+n
    elseif mode == 2
        pos = intcode[p+n]+relative_base[]
    else
        error("Unknown parameter mode '$mode'")
    end
    if pos > length(intcode)-1
        N = length(intcode)
        resize!(intcode,pos+1)
        intcode[N:end] .= zero(T)
    end
    return intcode[pos]
end

function param!(intcode,modes::Vector{T},p, n, relative_base, val) where T
    mode = length(modes) >= n ? modes[n] : 0
    if mode == 0
        pos = intcode[p+n]
    elseif mode == 1
        error("Can't set parameters with mode '$mode'")
    elseif mode == 2
        pos = intcode[p+n]+relative_base[]
    else
        error("Unknown parameter mode '$mode'")
    end
    if pos > length(intcode)-1
        N = length(intcode)
        resize!(intcode,pos+1)
        intcode[N:end] .= zero(T)
    end
    intcode[pos] = val
    return nothing
end

function get_modes(intcode,p)
    dig = digits(intcode[p])
    length(dig) > 2 && return dig[3:end]
    return Int[]
end

function execute!(::Val{1}, intcode, p, modes, relative_base, input, output)
    val = param(intcode,modes,p,2,relative_base) +
                            param(intcode,modes,p,1,relative_base)
    param!(intcode,modes,p,3,relative_base,val)
    return 4
end

function execute!(::Val{2}, intcode, p, modes, relative_base, input, output)
    val = param(intcode,modes,p,2,relative_base) *
                            param(intcode,modes,p,1,relative_base)
    param!(intcode,modes,p,3,relative_base,val)
    return 4
end

function execute!(::Val{3}, intcode, p, modes, relative_base, input, output)
    val = popfirst!(input)
    param!(intcode,modes,p,1,relative_base,val)
    return 2
end

function execute!(::Val{4}, intcode, p, modes, relative_base, input, output)
    push!(output, param(intcode,modes,p,1,relative_base))
    return 2
end

function execute!(::Val{5}, intcode, p, modes, relative_base, input, output)
    if param(intcode,modes,p,1,relative_base) != 0
        return param(intcode,modes,p,2,relative_base) - p
    end
    return 3
end

function execute!(::Val{6}, intcode, p, modes, relative_base, input, output)
    if param(intcode,modes,p,1,relative_base) == 0
        return param(intcode,modes,p,2,relative_base) - p
    end
    return 3
end

function execute!(::Val{7}, intcode, p, modes, relative_base, input, output)
    if param(intcode,modes,p,1,relative_base) < param(intcode,modes,p,2,relative_base)
        val = 1
    else
        val = 0
    end
    param!(intcode,modes,p,3,relative_base,val)
    return 4
end

function execute!(::Val{8}, intcode, p, modes, relative_base, input, output)
    if param(intcode,modes,p,1,relative_base) == param(intcode,modes,p,2,relative_base)
        val = 1
    else
        val = 0
    end
    param!(intcode,modes,p,3,relative_base,val)
    return 4
end

function execute!(::Val{9}, intcode, p, modes, relative_base, input, output)
    relative_base[] = relative_base[] + param(intcode,modes,p,1,relative_base)
    return 2
end

function run!(intcode_input::Vector{Int}; input=Int[], output=Int[])
    intcode = OffsetVector(intcode_input,0:length(intcode_input)-1)
    p = 0
    relative_base = Ref(zero(eltype(intcode_input)))
    while true
        intcode[p] == 99 && break
        # Get's the op no matter if in param or positional
        op = intcode[p] % 10
        modes = get_modes(intcode,p)
        p += execute!(Val(op), intcode, p, modes, relative_base, input, output)
    end
    resize!(intcode_input,length(intcode))
    # Update input incode back
    for i in 1:length(intcode_input)
        intcode_input[i] == intcode[i-1]
    end
    return output
end

intcode_from_file(path) = parse.(Int,split(strip(read(path,String)),","))
end