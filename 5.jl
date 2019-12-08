includet("IntComputer.jl")
using .IntComputer

# # Part 1
c = intcode_from_file("5.input")
run!(c,input=[1])

# # Part 2
c = intcode_from_file("5.input")
run!(c,input=[5])
