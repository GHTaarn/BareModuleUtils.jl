module BareModuleUtils

export generate_symbols, @init_without, @generate_eval, @generate_include
export @import_from_base, @using_from_base

function generate_symbols(m::Module; eval::Bool=true, include::Bool=true, baseskip=Symbol[])
    eval && generate_eval(m)
    include && generate_include(m)
    for sym in filter(∉(baseskip), names(Base))
        @eval m using Base: $(sym)
    end
end

function import_from_base(m::Module, syms...) # TODO: make sure that syms only contains Symbols
    for sym in syms
        @eval m import Base: $(sym)
    end
end

function using_from_base(m::Module, syms...) # TODO: make sure that syms only contains Symbols
    for sym in syms
        @eval m using Base: $(sym)
    end
end

function generate_eval(m::Module)
    @eval m eval(x) = Core.eval($(m), x)
end

function generate_include(m::Module)
    @eval m include(x) = Base.include($(m), x)
end

macro generate_eval()
    return :(generate_eval($(__module__)))
end

macro generate_include()
    return :(generate_include($(__module__)))
end

macro using_from_base(syms...)
    return :(using_from_base($(__module__), $(syms...)))
end

macro import_from_base(syms...)
    return :(import_from_base($(__module__), $(syms...)))
end

macro init_without(syms...)
    return :(generate_symbols($(__module__); baseskip=vcat($(syms...))))
end

end

