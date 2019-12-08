using Revise
using Combinatorics
includet("IntComputer.jl")
using .IntComputer

function setup_amplifierd_code(intcode) 
    function (phase::Int, input::Int)
        res = run!(copy(intcode),input=[phase, input])
        return res[end]
    end
end

function eval_phase(f,phases)
    v = 0
    for p in phases
        v = f(p,v)
    end
    return v
end

function find_max_phase(f)
    allp = map(permutations(0:4)) do phases
        phases=>eval_phase(f,phases)
    end
    allp[argmax(map(x->x[2],allp))]
end

# Test 1
code = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
amplifier = setup_amplifierd_code(code)
find_max_phase(amplifier)

code = [3,23,3,24,1002,24,10,24,1002,23,-1,23, 101,5,23,23,1,24,23,23,4,23,99,0,0]
amplifier = setup_amplifierd_code(code)
find_max_phase(amplifier)

code = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33, 1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
amplifier = setup_amplifierd_code(code)
find_max_phase(amplifier)

code = intcode_from_file("7.input")
amplifier = setup_amplifierd_code(code)
find_max_phase(amplifier)

# # Part 2

function setup_feedback_loop(intcode, channels) 
    [ @async run!(copy(intcode), input=channels[1], output=channels[2])
      @async run!(copy(intcode), input=channels[2], output=channels[3])
      @async run!(copy(intcode), input=channels[3], output=channels[4])
      @async run!(copy(intcode), input=channels[4], output=channels[5])
      @async run!(copy(intcode), input=channels[5], output=channels[1])]
end

function eval_phase_feedback(code, phase_setting)
    channels = [Channel{Int}(1) for _ in 1:5]
    tasks = setup_feedback_loop(code,channels)
    push!.(channels,phase_setting)
    push!(channels[1],0)
    wait.(tasks)
    return take!(channels[1])
end

function find_max_phase_feedback(code)
    allp = map(permutations(5:9)) do phases
        phases=>eval_phase_feedback(code,phases)
    end
    allp[argmax(map(x->x[2],allp))]
end

code = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26, 27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
phase_setting = [9,8,7,6,5]
eval_phase_feedback(code, phase_setting)
find_max_phase_feedback(code)

code = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]
phase_setting = [9,7,8,5,6 ]
eval_phase_feedback(code, phase_setting)
find_max_phase_feedback(code)

code = intcode_from_file("7.input")
find_max_phase_feedback(code)