using DelimitedFiles

mutable struct Object{T}
    child::T
    Object{T}() where T = new{T}()
end

function parse_input(def)
    d = Dict{String, Object}()
    for r in def
        A, B = split(r,')')
        _A = get!(d,A,Object{Object}())
        _B = get!(d,B,Object{Object}())
        _B.child = _A
    end
    return d
end

v = ["COM)B",
"B)C",
"C)D",
"D)E",
"E)F",
"B)G",
"G)H",
"D)I",
"E)J",
"J)K",
"K)L",
"K)YOU",
"I)SAN"]

function count_til_last(o::Object,i=0)
    try
        count_til_last(o.child,i+1)
    catch e
        return i
    end
end

t = parse_input(v)
sum(count_til_last.(values(t)))

f = readdlm("6.input")
t = parse_input(f)
sum(count_til_last.(values(t)))

# # Part 2

function all_orbits(o::Object,found=Object{Object}[])
    try
        push!(found,o)
        all_orbits(o.child,found)
    catch e
        return found
    end
end

function count_distance(o1,o2)
    # find common ancestor
    for (i,oi) in enumerate(o1)
        for (j,oj) in enumerate(o2)
            if oi === oj
                return i+j-4
            end
        end
    end
end
YOU = all_orbits(t["YOU"])
SAN = all_orbits(t["SAN"])
count_distance(YOU, SAN)
