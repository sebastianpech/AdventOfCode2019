function to_tup(s)
    num, name = split(s," ")
    return parse(Int,num), Symbol(name)
end

function parse_input(input)
    re = r"(\d+ \w+){1,}"
    map(split(strip(input),"\n")) do eqn
        m = (x->x.match).(collect(eachmatch(re,eqn)))
        to_tup(m[end]) => to_tup.(m[1:end-1])
    end |> Dict
end

mutable struct Factory
    ore_counter::Int
    storage::Dict{Symbol,Int}
    reactions
    chemicals
    Factory(reactions) = new(0,Dict{Symbol,Int}(), reactions, collect(keys(reactions)))
end

function produce!(f::Factory,chemical,n)
    Δn = n-get(f.storage,chemical,0)
    if chemical == :ORE
        f.ore_counter += n
    elseif Δn > 0
        k = f.chemicals
        matching = k[findfirst(x->x[2]==chemical,k)]
        scale = (Δn-1) ÷ matching[1] + 1
        foreach(f.reactions[matching]) do c
            produce!(f,c[2],c[1]*scale)
        end
        Δstorage = matching[1]*scale - Δn
        f.storage[matching[2]] = Δstorage
    else
        f.storage[chemical] = -Δn
    end
end

example01 = """
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL
"""

f = Factory(parse_input(example01))
produce!(f,:FUEL,1)
f.ore_counter

example02 = """
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
"""

f = Factory(parse_input(example02))
produce!(f,:FUEL,1)
f.ore_counter

example03 = """
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
"""

f = Factory(parse_input(example03))
produce!(f,:FUEL,1)
f.ore_counter

f = Factory(parse_input(read("14.input",String)))
produce!(f,:FUEL,1)
f.ore_counter

using ProgressMeter

function part02(input)
    f = Factory(parse_input(read(input,String)))
    c = 0
    p = ProgressUnknown("Calculating")
    while f.ore_counter < 1000000000000
        produce!(f,:FUEL,1)
        next!(p)
        c += 1
    end
    finish!(p)
    return c
end

part02("14.input")

