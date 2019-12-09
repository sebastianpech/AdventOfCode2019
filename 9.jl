using Revise
using Test
includet("IntComputer.jl")
using .IntComputer

# Part 1
code = intcode_from_file("9.input")
res = run!(code,input=[1])

# Part 1
code = intcode_from_file("9.input")
res = run!(code,input=[2])