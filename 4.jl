function part1()
    c = 0
    v = zeros(Int,6)
    for i1 in 1:9
        v[1] = i1
        for i2 in i1:9
            v[2] = i2
            for i3 in i2:9
                v[3] = i3
                for i4 in i3:9
                    v[4] = i4
                    for i5 in i4:9
                        v[5] = i5
                        for i6 in i5:9
                            v[6] = i6
                            if is_valid_code(v)
                                c += 1
                            end
                        end
                    end
                end
            end
        end
    end
    return c
end

function is_valid_code(c)
    N = length(c)
    @inbounds num = sum(c[i]*10^(N-i) for i in 1:N)
    lower = 193651
    upper = 649729
    lower <= num <= upper || return false
    any(i -> i == 0, c[1:end-1] - c[2:end]) && return true
    return false
end

is_valid([2,3,3,6,7,9])
is_valid_code([1,2,3,4,7,8,9])

part1()

function part2()
    c = 0
    v = zeros(Int,6)
    for i1 in 1:9
        v[1] = i1
        for i2 in i1:9
            v[2] = i2
            for i3 in i2:9
                v[3] = i3
                for i4 in i3:9
                    v[4] = i4
                    for i5 in i4:9
                        v[5] = i5
                        for i6 in i5:9
                            v[6] = i6
                            if is_valid_code2(v)
                                c += 1
                            end
                        end
                    end
                end
            end
        end
    end
    return c
end

function find_group(c,i)
    N = length(c)
    i == N && return 1
    c[i+1] != c[i] && return 1
    len = 1
    for idx in i:N-1
        if c[idx] == c[idx+1]
            len += 1
        else
            return len
        end
    end
    return len
end

function is_valid_code2(c)
    N = length(c)
    @inbounds num = sum(c[i]*10^(N-i) for i in 1:N)
    lower = 193651
    upper = 649729
    lower <= num <= upper || return false
    idx = 1
    while idx <= N-1
        len = find_group(c,idx)
        idx += len
        len == 2 && return true
    end
    return false
end

part2()