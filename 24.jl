using OffsetArrays

example01 = """
....#
#..#.
#..##
..#..
#....
"""

parse_input(input) = reduce(vcat,permutedims.(map.(first,split.(split(strip(input),'\n'),Ref("")))))

function get_tile(world,i,j) 
    1 <= i <= size(world,1) || return '.'
    1 <= j <= size(world,1) || return '.'
    return world[i,j]
end

function evolute(world)
    new_world = similar(world)
    for i in 1:size(new_world,1)
        for j in 1:size(new_world,2)
            bug_count = (get_tile(world,i-1,j) == '#') + (get_tile(world,i+1,j) == '#') + (get_tile(world,i,j+1) == '#') + (get_tile(world,i,j-1) == '#')
            if world[i,j] == '#'
                if bug_count == 1
                    new_world[i,j] = '#'
                else
                    new_world[i,j] = '.'
                end
            else
                if 0 < bug_count <= 2
                    new_world[i,j] = '#'
                else
                    new_world[i,j] = world[i,j]
                end
            end
        end
    end
    return new_world
end

function biodiversity(world)
    diver = 0
    for i in 1:size(world,1)
        for j in 1:size(world,2)
            if world[i,j] == '#'
                diver += 2^(size(world,2)*(i-1)+(j-1))
            end
        end
    end
    return diver
end

function part01(file)
    world = parse_input(read(file,String))
    worlds = Set([copy(world)])
    for i in 1:1000
        world = evolute(world)
        if world in worlds
            return world
        else
            push!(worlds,copy(world))
        end
    end
end

biodiversity(part01("./24.input"))

function get_bug_count(world,i,j,l,i_from,j_from)
    if i < 1
        _i = 2
        _j = 3
        _l = l-1
    elseif i > 5
        _i = 4
        _j = 3
        _l = l-1
    elseif j < 1
        _i = 3
        _j = 2
        _l = l-1
    elseif j > 5
        _i = 3
        _j = 4
        _l = l-1
    elseif i == j == 3 && i_from == 4
        return sum(world[5,:,l+1].=='#')
    elseif i == j == 3 && i_from == 2
        return sum(world[1,:,l+1].=='#')
    elseif i == j == 3 && j_from == 4
        return sum(world[:,5,l+1].=='#')
    elseif i == j == 3 && j_from == 2
        return sum(world[:,1,l+1].=='#')
    else
        _i = i
        _j = j
        _l = l
    end
    return 1*(world[_i,_j,_l] == '#')
end



function evolute_layers(world)
    new_world = copy(world)
    min_max_layer = ((size(world,3)-1) ÷ 2) -1
    for l in -min_max_layer:min_max_layer
        all(world[:,:,l] .== '.') && all(world[:,:,l+1] .== '.') && all(world[:,:,l-1] .== '.') && continue
        for i in 1:size(new_world,1)
            for j in 1:size(new_world,2)
                bug_count = get_bug_count(world,i-1,j,l,i,j) + get_bug_count(world,i+1,j,l,i,j) + get_bug_count(world,i,j+1,l,i,j) + get_bug_count(world,i,j-1,l,i,j)
                if world[i,j,l] == '#'
                    if bug_count == 1
                        new_world[i,j,l] = '#'
                    else
                        new_world[i,j,l] = '.'
                    end
                else
                    if 0 < bug_count <= 2
                        new_world[i,j,l] = '#'
                    else
                        new_world[i,j,l] = world[i,j,l]
                    end
                end
            end
        end
    end
    return new_world
end

function evolute_layers(world,N)
    for _ in 1:N
        world = evolute_layers(world)
    end
    return world
end

world = OffsetArray{Char}(undef,1:5,1:5,-101:101)
world .= '.'
world[:,:,0] = parse_input(read("./24.input",String))
world = evolute_layers(world,200)

count(world .== '#') - count(world[3,3,:].=='#')