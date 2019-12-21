using Revise
includet("IntComputer.jl"); using .IntComputer

function init_springdroid(file)
    code = intcode_from_file(file)
    function (program::Vector{String})
        input = map(x->Int(x[1]),split(join(program,"\n")*"\n",""))
        run!(copy(code); input=input)
    end
end

springdroid = init_springdroid("21.input")
res = springdroid([
    "NOT C J",
    "NOT A T",
    "OR T J",
    "AND D J",
    "WALK"
])
res

springdroid = init_springdroid("21.input")
@time res = springdroid([
    "NOT C J",
    "NOT A T",
    "OR T J",
    "NOT E T",
    "NOT T T",
    "OR  H T",
    "AND T J",
    "NOT B T",
    "NOT T T",
    "OR E T",
    "NOT T T",
    "OR T J",
    "AND D J",
    "RUN"
]);

# (print∘Char).(res)

res
