module TestAbstractTypes

using Test

const niters = 1 #TODO 100

function generator end
export generator

################################################################################

function generator(::Type{Char})
    function gen(channel::Channel{Char})
        yield!(x) = put!(channel, x)
        while true
            case = rand(1:20)
            if case == 1
                yield!('a')
            elseif case == 2
                yield!("β")
            elseif case == 3
                yield!(' ')
            elseif case == 4
                yield!('\0')
            elseif case == 5
                yield!(Char(127))
            elseif case == 6
                yield!(Char(128))
            elseif case ≤ 10
                yield!(Char(rand(0:127)))
            else
                len = rand(0:20)
                yield!(rand(Char))
            end
        end
    end
    return Channel{Char}(gen)
end

function testAbstractChar(::Type{T}, ch::AbstractChannel{T}) where {T}
    @testset "testAbstractChar($T)" begin
        @test T <: AbstractChar

        next!() = take!(ch)::T

        for iter in 1:niters
            x = next!()
            y = next!()

            if x == y
                @test cmp(x, y) == 0
            elseif x < y
                @test cmp(x, y) == -1
            elseif x > y
                @test cmp(x, y) == 1
            else
                @test false
            end

            xp = codepoint(x)
            @test xp isa Integer
            xc = T(xp)
            @test xc isa T
            @test xc == x
        end
    end
end
export testAbstractChar

################################################################################

function generator(::Type{String})
    function gen(channel::Channel{String})
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
    return Channel{String}(gen)
end

function generator(::Type{SubString})
    function gen(channel::Channel{SubString})
        source = generator(String)
        while true
            str = take!(source)::String
            len = ncodeunits(str)
            if len == 0
                put!(channel, SubString(str))
            else
                i = thisind(str, rand(1:len))
                j = thisind(str, rand(1:len))
                if i ≤ j
                    put!(channel, SubString(str, i, j))
                end
            end
        end
    end
    return Channel{SubString}(gen)
end

function testAbstractString(::Type{T}, ch::AbstractChannel{T}) where {T}
    @testset "testAbstractString($T)" begin
        @test T <: AbstractString

        next!() = take!(ch)::T

        unit = T("")

        @test unit isa T
        @test length(unit) == 0

        for iter in 1:niters
            x = next!()
            y = next!()
            z = next!()

            # Equality
            @test unit == unit
            @test x == x

            # Unit
            @test unit * unit == unit
            @test unit * x == x
            @test x * unit == x

            # Associativity
            @test (x * y) * z == x * (y * z)

            # Exponentiation
            @test x^0 == unit
            @test x^1 == x
            @test x^2 == x * x
            n = rand(3:10)
            @test x^n == *((x for i in 1:n)...)

            # Lengths
            @test length(x) isa Int
            @test length(x * y) == length(x) + length(y)
            @test isempty(x) == (length(x) == 0)
            @test ncodeunits(x) isa Int
            @test ncodeunits(x * y) == ncodeunits(x) + ncodeunits(y)
            @test isempty(x) == (ncodeunits(x) == 0)

            # Elements
            # Find all possible indices
            inds = Int[]
            ind = firstindex(x)
            while ind ≤ lastindex(x)
                push!(inds, ind)
                ind = nextind(x, ind)
            end
            @test length(inds) == length(x)
            if !isempty(x)
                pos = inds[rand(1:length(inds))]
                @test eltype(x) isa Type
                @test x[pos] isa eltype(x)
                @test (x * y)[pos] == x[pos]
                @test (y * x)[ncodeunits(y) + pos] == x[pos]
            end

            # codeunit, codeunits
            # firstindex, lastindex, thisind, nextind, prevind, isvalid
            # cmp
        end

        close(ch)
    end
end
export testAbstractString

end
