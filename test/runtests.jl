using Random
using TestAbstractTypes

# Set reproducible random number seed
Random.seed!(0)
testAbstractChar(Char, generator(Char))

# Set reproducible random number seed
Random.seed!(0)
testAbstractString(String, generator(String))

# Set reproducible random number seed
Random.seed!(0)
testAbstractString(SubString, generator(SubString))
