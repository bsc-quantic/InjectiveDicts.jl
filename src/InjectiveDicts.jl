module InjectiveDicts

export InjectiveDict

struct InjectiveDict{K,V,F<:AbstractDict{K,V},F⁻¹<:AbstractDict{V,Set{K}}} <: AbstractDict{K,V}
    f::F
    f⁻¹::F⁻¹

    InjectiveDict(f::F, f⁻¹::F⁻¹) where {K,V,F<:AbstractDict{K,V},F⁻¹<:AbstractDict{V,Set{K}}} = new{K,V,F,F⁻¹}(f, f⁻¹)
    InjectiveDict{K,V,F,F⁻¹}(f::F, f⁻¹::F⁻¹) where {K,V,F<:AbstractDict{K,V},F⁻¹<:AbstractDict{V,Set{K}}} = new{K,V,F,F⁻¹}(f, f⁻¹)
end

# InjectiveDict{K,V,F,F⁻¹}(pairs::Pair{K,V}...) where {K,V,F,F⁻¹} = InjectiveDict{K,V,F,F⁻¹}(F(pairs...), F⁻¹(Iterators.map(reverse, pairs)))

Base.copy(id::InjectiveDict) = InjectiveDict(copy(id.f), copy(id.f⁻¹))
function Base.empty(id::InjectiveDict, ::Type{K}, ::Type{V}) where {K,V}
    InjectiveDict(empty(id.f, K, V), empty(id.f⁻¹, V, K))
end

Base.length(id::InjectiveDict) = length(id.f)

Base.getindex(id::InjectiveDict{K,V}, key::K) where {K,V} = getindex(id.f, key)
function Base.setindex!(id::InjectiveDict{K,V}, value::V, key::K) where {K,V}
    # haskey(id.f⁻¹, value) && throw(ArgumentError("inserting $key => $value would break bijectiveness"))
    id.f[key] = value
    id.f⁻¹[value] = key
end

Base.iterate(id::InjectiveDict) = iterate(id.f)
Base.iterate(id::InjectiveDict, s) = iterate(id.f, s)

Base.get(id::InjectiveDict, key, default) = get(id.f, key, default)

function Base.sizehint!(id::InjectiveDict, sz)
    sizehint!(id.f, sz)
    sizehint!(id.f⁻¹, sz)
    id
end


struct SurjectiveDict{K,V,ID<:InjectiveDict{V,K}} <: AbstractDict{K,Set{V}}
    wrap::ID
end

Base.adjoint(::Type{T}) where {K,V,F,F⁻¹,T<:InjectiveDict{K,V,F,F⁻¹}} = SurjectiveDict{V,K,T}
Base.adjoint(id::InjectiveDict) = SurjectiveDict(id)
Base.adjoint(sd::SurjectiveDict) = sd.wrap

Base.length(sd::SurjectiveDict) = length(sd.wrap)

Base.getindex(sd::SurjectiveDict{K,V}, key::K) where {K,V} = getindex(sd.wrap.f⁻¹, key)

Base.iterate(sd::SurjectiveDict) = iterate(sd.wrap.f⁻¹)
Base.iterate(sd::SurjectiveDict, s) = iterate(sd.wrap.f⁻¹, s)

function Base.sizehint!(sd::SurjectiveDict, sz)
    sizehint!(sd.wrap.f, sz)
    sizehint!(sd.wrap.f⁻¹, sz)
    sd
end

end
