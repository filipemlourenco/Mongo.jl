export insert_bulk

## Bulk insert
function insert_bulk(collection::Mongo.MongoCollection,
documents::Vector{Mongo.BSONObject},
flags::Int = Mongo.MongoInsertFlags.None)
bulk = ccall((:mongoc_collection_create_bulk_operation, Mongo.libmongoc),
 Ptr{Void}, (Ptr{Void}, Bool, Ptr{Void}),
 collection._wrap_, true, C_NULL)

for doc in documents
    ccall((:mongoc_bulk_operation_insert, Mongo.libmongoc),
    Void, (Ptr{Void}, Ptr{Void}),
    bulk, doc._wrap_)
end

reply = LibBSON.BSONObject()

ret = ccall((:mongoc_bulk_operation_execute, Mongo.libmongoc),
Bool, (Ptr{Void}, Ptr{Void}, Ptr{Void}),
bulk,
      reply._wrap_,
      C_NULL
            )

ccall((:mongoc_bulk_operation_destroy, Mongo.libmongoc),
      Void, (Ptr{Void},), bulk)

return ret
end
