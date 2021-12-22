module TestAbstractTypes

using Test

const niters = 100

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
        end

        close(ch)
    end
end
export testAbstractString

end
