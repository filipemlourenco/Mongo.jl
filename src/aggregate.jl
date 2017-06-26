export mongo_aggregate
############ Mongo Aggregate (requires mongoc v1.3.5)#################################
function mongo_aggregate(collection::Mongo.MongoCollection,pipeline::Array,options::Dict=Dict("allowDiskUse"=>false))

pipe_dict=LibBSON.BSONObject(OrderedDict("pipeline"=>pipeline))

options=LibBSON.BSONObject(options)

agg=ccall((:mongoc_collection_aggregate, Mongo.libmongoc), Ptr{Void}, (Ptr{Void},Cint,Ptr{Void},Ptr{Void},Ptr{Void}),
 collection._wrap_,
0,
pipe_dict._wrap_,
options._wrap_,
C_NULL
)

    return Mongo.MongoCursor(agg)

end
