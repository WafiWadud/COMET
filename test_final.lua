io.write("=== String Concatenation ===\n")
local str1 = "Hello"
local str2 = "World"
local result = ((str1 .. " ") .. str2)
io.write(result)
io.write("\n")
io.write("=== String Length ===\n")
io.write("Length: ")
io.write((#result))
io.write("\n")
io.write("=== String Interpolation ===\n")
local name = "Alice"
local age = 30
local info = "Hello " .. name .. " you are " .. age .. "years old"
io.write(info)
io.write("\n")
io.write("=== Array Length ===\n")
local arr = {10, 20, 30}
io.write("Array size: ")
io.write((#arr))
io.write("\n")
io.write("=== Otherwise (else) ===\n")
local x = 5
if (x > 10) then
io.write("x > 10")
else
io.write("x <= 10")
end
io.write("=== Otherwise with Condition (else if) ===\n")
local y = 15
if (y > 20) then
io.write("y > 20")
elseif (y < 10) then
io.write("y < 10")
else
io.write("10 <= y <= 20")
end
io.write("=== Done ===\n")
