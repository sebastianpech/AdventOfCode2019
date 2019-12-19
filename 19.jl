using Revise
includet("IntComputer.jl"); using .IntComputer

function drone(code)
    function (x,y)
        first(run!(copy(code), input=[x,y])) == 1
    end
end

code = intcode_from_file("19.input")
d = drone(code)

count([d(x,y) for x in 0:49, y in 0:49])

function part02(drone,target_length=100)
    d = drone
    x_start_search = 0
    tractorbeam = Tuple{Int,Int}[]
    expected_length = 0
    y = 10
    while expected_length < 2.5*target_length
        y += 1
        x = x_start_search
        # Search for start
        while !d(x,y)
            x += 1
        end
        x_from = x
        # Search for end
        x += expected_length
        while d(x,y)
            x += 1
        end
        x -= 1
        expected_length = x-x_from
        x_start_search = x_from
        push!(tractorbeam,(x_from,x))
    end
    return tractorbeam
end

code = intcode_from_file("19.input")
p = part02(drone(code))
d = drone(code)

idx = 1
while (idx = findnext(x->x[2]-x[1]+1>=100,p,idx)) != nothing
    global idx
    length(p) < idx+99 && break
    o1 = p[idx]
    o2 = p[idx+99]
    if o1[1]+99 <= o2[2] && o2[1]+99 <= o1[2]
        @show o2[1]*10000 + idx+10
        break
    end
    idx += 1
end