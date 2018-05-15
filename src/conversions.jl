using DataFrames,Missings

export cursor_dicts,dicts_df

function cursor_dicts(cursor::Mongo.MongoCursor)

arr=[]
for r in cursor
d=Dict()

        d=LibBSON.dict(r)
        try merge!(d,d["_id"]) catch "" end
        try delete!(d,"_id") catch "" end
        push!(arr,d)

end

    return arr
end

function dicts_df(dicts::Array,header=[])

df=DataFrame()

    ###check if header defined
    header==[] ? k=keys(dicts[1]) : k=header


        for rk in k

            ark=[]

                for row in dicts

                    haskey(row,rk)? push!(ark,(row[rk])) : push!(ark,missing)

                end

            #=if typeof(ark[1])==String
            df[Symbol(rk)]=@data(map(String,ark))
          else

          end
          =#
            df[Symbol(rk)]=(map(x->x,ark))

        end

    return df_stab_types(df)
end

############# Function stab types
function df_stab_types(df)
fields=names(df)
rows=size(df,1)
def_type=Any
sample_n_arr=map(x->Int(ceil(x)),(rand(100)*rows))
sample_arr=[]

for f in fields


    for r in sample_n_arr

        push!(sample_arr,typeof(df[f][r]))

    end

sample_arr=unique(sample_arr)


    for s in sample_arr

        if s <: AbstractFloat
            def_type=Float64
            break
        end

        if s == Date
            def_type=Date
            break
        end


        if s == DateTime
            def_type=DateTime
            break
        end


        if s <: Integer
            def_type=Int64
            break
        end

        if s <: String
            def_type=String
            break
        end

    end

try df[f]=convert(Array{def_type,1}, df[f])  catch df[f]=convert(Array{Any,1}, df[f]) end

def_type=Any
sample_arr=[]
end

    return df
end

