using DelimitedFiles
# # Part 1
# Fuel required to launch a given module is based on its mass.
# Specifically, to find the fuel required for a module, 
# - take its mass, 
# - divide by three, 
# - round down, and 
# - subtract 2.

required_fuel(m) = floor(m/3)-2

data = readdlm("1-1.input")

Int(mapreduce(required_fuel,+,data))

# # Part 2
function required_fuel_fuel(m)
    Δf = required_fuel(m)
    f = Δf
    while (Δf = required_fuel(Δf)) > 0
        f += Δf
    end
    return f
end

Int(mapreduce(required_fuel_fuel,+,data))