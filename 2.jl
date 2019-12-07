const cmds = Dict(
    1=>+,
    2=>*,
)

function call!(intcode,n)
    optcode = @view intcode[n:n+3]
    cmd = cmds[optcode[1]]
    A,B = intcode[optcode[2]+1],intcode[optcode[3]+1]
    intcode[optcode[4]+1] = cmd(A,B)
end

function run_Intcode(intcode)
    for n in 1:4:length(intcode)
        intcode[n] == 99 && break
        intcode[n] > 2 && break
        call!(intcode,n)
    end
end

code = [1,0,0,0,99]
run_Intcode(code)
code

code = [ 2,3,0,3,99 ]
run_Intcode(code)
code

code = [2,4,4,5,99,0]
run_Intcode(code)
code

code = [1,1,1,4,99,5,6,0,99]
run_Intcode(code)
code

# # Part 1
# To do this, before running the program, replace position 1 with the value 12
# and replace position 2 with the value 2. What value is left at position 0
# after the program halts?
function init(noun,verb) 
    code = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,6,19,1,5,19,23,1,23,6,27,1,5,27,31,1,31,6,35,1,9,35,39,2,10,39,43,1,43,6,47,2,6,47,51,1,5,51,55,1,55,13,59,1,59,10,63,2,10,63,67,1,9,67,71,2,6,71,75,1,5,75,79,2,79,13,83,1,83,5,87,1,87,9,91,1,5,91,95,1,5,95,99,1,99,13,103,1,10,103,107,1,107,9,111,1,6,111,115,2,115,13,119,1,10,119,123,2,123,6,127,1,5,127,131,1,5,131,135,1,135,6,139,2,139,10,143,2,143,9,147,1,147,6,151,1,151,13,155,2,155,9,159,1,6,159,163,1,5,163,167,1,5,167,171,1,10,171,175,1,13,175,179,1,179,2,183,1,9,183,0,99,2,14,0,0]
    code[2] = noun
    code[3] = verb
    return code
end
input = init(12,2)
run_Intcode(input)
@show input[1]

# # Part 2
function searchp2()
    for noun in 1:99
        for verb in 1:99
            code = init(noun,verb)
            run_Intcode(code)
            code[1] == 19690720 && return noun,verb
        end
    end
    return (0,0)
end

noun, verb = searchp2()
@show 100 * noun + verb