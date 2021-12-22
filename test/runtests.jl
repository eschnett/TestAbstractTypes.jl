using Random
using TestAbstractTypes

# Set reproducible random number seed
Random.seed!(0)

function generate_strings(channel::Channel{String})
    yield!(x) = put!(channel, x)
    while true
        case = rand(1:20)
        if case == 1
            yield!("")
        elseif case == 2
            yield!("a")
        elseif case == 3
            yield!("abc")
        elseif case == 4
            yield!("β")
        elseif case == 5
            yield!(" ")
        elseif case == 6
            yield!("\0")
        elseif case == 7
            yield!("\0abc")
        elseif case ≤ 10
            yield!(string(rand(Char)))
        elseif case ≤ 19
            len = rand(0:20)
            yield!(String(rand(Char, len)))
        else
            len = rand(10000:20000)
            yield!(String(rand(Char, len)))
        end
    end
end

const generator = Channel{String}(generate_strings)

testAbstractString(String, generator)
