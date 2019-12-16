to_list(input::Int) = reverse(digits(input))
to_list(input::String) = parse.(Int,split(strip(input),""))

function fft(list, output=zeros(Int,length(list)))
    base_pattern = [0, 1, 0, -1]
    N=length(list)
    @inbounds for i in 1:N
        j = i
        output[i] = 0
        while j<=N
            idx = (j÷i)%4+1
            if idx == 3 || idx == 1
                j += i
                continue
            end
            output[i] += list[j]*base_pattern[idx]
            j+= 1
        end
    end
    return @. abs(output)%10
end

function fftN(list,N)
    output = zeros(Int,length(list))
    for i in 1:N
        list = fft(list,output)
    end
    return list
end

l = to_list(read("./16.input",String))

fftN(l,100)

function part02(inp::Vector,n=1)
    d = repeat(inp,10_000)
    offset = sum([d*10^(i-1) for (i,d) in enumerate(reverse(d[1:7]))])+1
    partial = d[offset:end]
    result = similar(partial)
    result[end] = partial[end]
    for _ in 1:n
        for i=length(partial)-1:-1:1
            result[i] = abs(result[i+1]+partial[i])%10
        end
        partial .= result
    end
    return result
end
part02(file::String,n=1) = part02(to_list(read(file,String)),n)
part02(file::String,n=1) = part02(to_list(read(file,String)),n)

part02(to_list("03036732577212944063491565474664"),100)[1:8]

res = part02("./16.input",100)
print.(res[1:8])
