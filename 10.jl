function get_locations(data)
    rows = split(data,"\n")
    output = Set{(Tuple{Int,Int})}()
    for (y,r) in enumerate(rows)
        for (x,e) in enumerate(split(r,""))
            e == "#" && push!(output,(x-1,y-1))
        end
    end
    return output
end

function hits(p1,p2,p)
    if p1[1] == p2[1] == p[1]
        x = (p[2] - p1[2])/(p2[2]-p1[2])
    elseif p1[2] == p2[2] == p[2]
        x = (p[1] - p1[1])/(p2[1]-p1[1])
    elseif p1[1] == p2[1] || p1[2] == p2[2]
        return false
    else
        x1 = (p .- p1)./(p2.-p1)
        x1[1] ≈ x1[2] || return false
        x = x1[1]
    end
    return 0.0 <= x <= 1.0
end

function check_intersections(coords)
    coord_count = Dict{Tuple{Int,Int},Int}()
    for testp in coords
        coord_count[testp] = check_intersections(coords,testp)
    end
    return coord_count
end

function check_intersections(coords,testp)
    c = 0
    for reach in coords
        reach == testp && continue
        any(hits(testp,reach,p) for p in coords if p != testp && p != reach) && continue
        c += 1
    end
    return c
end

data = """.#..#
.....
#####
....#
...##"""

coords = get_locations(data)
check_intersections(coords)

coords = get_locations(read("10.input",String))
inter = check_intersections(coords)

function in_sight(coords,testp)
    in_sight = Set{Tuple{Int,Int}}()
    for reach in coords
        reach == testp && continue
        any(hits(testp,reach,p) for p in coords if p != testp && p != reach) && continue
        push!(in_sight,reach)
    end
    return in_sight
end

function angle(p1,p2)
    v1 = p2.-p1
    a = pi/2-atan(-v1[2],v1[1])
    a < 0 && return (2π+a)%(2π)
    return a%(2π)
end

function vaporize_circle(coords,testp)
    sight = collect(in_sight(coords,testp))
    sort!(sight,by=x->angle(testp,x))
end

function vaporize(coords,testp)
    _coords = copy(coords)
    vaporized = Tuple{Int,Int}[]
    while length(_coords) > 1
        vap = vaporize_circle(_coords,testp)
        append!(vaporized,vap)
        setdiff!(_coords,Set(vap))
    end
    return vaporized
end

data = """.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##"""

coords = get_locations(data)
res = vaporize(coords,(11,13))
res[200]

coords = get_locations(read("10.input",String))
res = vaporize(coords,(19,11))
res[200][1]*100+res[200][2]