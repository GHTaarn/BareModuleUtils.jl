using Test

baremodule A
    import Base
    using BareModuleUtils
    @generate_eval
    mymodule = eval(Base.Meta.parse("Base.@__MODULE__"))
end

baremodule B
    import Base
    using BareModuleUtils
    @generate_include
    include("$(Base.@__DIR__)/B-functions.jl")
end

baremodule C
    import BareModuleUtils
    BareModuleUtils.@init_without :isopen Symbol("'")
end

@testset "eval" begin
    @test A.mymodule == A
    @test isdefined(A, :eval)
    @test length(methods(A.eval)) == 1
    @test length(methods(B.eval)) == length(methods(Core.eval))
    @test length(methods(C.eval)) == 1
end

@testset "include" begin
    @test B.mymodule == B
    @test isdefined(B, :include)
    @test !isdefined(A, :include)
    @test isdefined(C, :include)
end

@testset "@init_without" begin
    for mod in [A, B, C]
        @test isdefined(mod, :Base)
        @test !isdefined(mod, :isopen)
        @test !isdefined(mod, Symbol("'"))
    end
    @test !isdefined(A, :filter)
    @test !isdefined(B, :filter)
    @test isdefined(C, :filter)
    @test isdefined(C, Symbol("|>"))
    @test isdefined(C, Symbol("÷"))
end
