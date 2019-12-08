using Revise
using Test
includet("IntComputer.jl")
using .IntComputer

@testset "IntComputer" begin
    code = [1,0,0,0,99]; run!(code)
    @test code == [2,0,0,0,99]

    code = [2,3,0,3,99]; run!(code)
    @test code == [2,3,0,6,99]

    code = [2,4,4,5,99,0]; run!(code)
    @test code == [2,4,4,5,99,9801]

    code = [1,1,1,4,99,5,6,0,99]; run!(code)
    @test code == [30,1,1,4,2,5,6,0,99]

    code = intcode_from_file("2.input"); 
    code[2] = 12
    code[3] = 2
    run!(code)
    @test code[1] == 4023471

    code = intcode_from_file("5.input"); 
    res = run!(code,input=[1])
    @test res[end] == 12428642

    function eq8(x)
        codePos = [3,9,8,9,10,9,4,9,99,-1,8]
        codeImm = [3,3,1108,-1,8,3,4,3,99]
        first(run!(codePos,input=[x])) == 1 && first(run!(codeImm,input=[x])) == 1
    end

    function lt8(x)
        codePos = [3,9,7,9,10,9,4,9,99,-1,8]
        codeImm = [3,3,1107,-1,8,3,4,3,99]
        first(run!(codePos,input=[x])) == 1 && first(run!(codeImm,input=[x])) == 1
    end

    @test eq8(8)
    @test !eq8(-1)
    @test !eq8(9)
    @test !eq8(123)
    @test !eq8(123234234)
    @test !eq8(0)

    @test !lt8(8)
    @test lt8(-1)
    @test !lt8(9)
    @test !lt8(123)
    @test !lt8(123234234)
    @test lt8(0)

    function isZero(x)
        codePos = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
        codeImm = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
        first(run!(codePos,input=[x])) == 0 && first(run!(codeImm,input=[x])) == 0
    end

    @test !isZero(1)
    @test !isZero(-1)
    @test !isZero(100)
    @test !isZero(123123)
    @test isZero(0)


    function larger8(x)
        code = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
                1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
                999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
        first(run!(code,input=[x]))
    end

    @test larger8(10) == 1001
    @test larger8(-9) == 999
    @test larger8(8) == 1000

    code = intcode_from_file("5.input"); 
    @test run!(code,input=[5]) == [918655,]
end