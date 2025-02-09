using FactCheck, LibBSON, Mongo, DataStructures

facts("Mongo") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    oid = BSONOID()

    context("variables") do
      @fact collection.client --> client
      @fact collection.db --> "foo"
      @fact collection.name --> "bar"
    end

    context("insert") do
        insert(collection, ("_id" => oid, "hello" => "before"))
        @fact count(collection, ("_id" => oid)) --> 1
        @fact count(collection) --> 1
        for item in find(collection, ("_id" => oid), ("_id" => false, "hello" => true))
            @fact dict(item) --> Dict("hello" => "before")
        end
    end

    context("update") do
        update(
            collection,
            ("_id" => oid),
            set("hello" => "after")
            )
        @fact count(collection, ("_id" => oid)) --> 1
        for item in find(collection, ("_id" => oid), ("_id" => false, "hello" => true))
            @fact dict(item) --> Dict("hello" => "after")
        end
    end

    context("command_simple") do
        reply = command_simple(
            client,
            "foo",
            OrderedDict(
               "count" => "bar",
               "query" => Dict("_id" => oid))
            )
        @fact reply["n"] --> 1
    end

    context("delete") do
        delete(
            collection,
            ("_id" => oid)
            )
        @fact count(collection, ("_id" => oid)) --> 0
        @fact count(collection) --> 0
    end

    context("pipeline") do
        col = MongoCollection(client, "foo", "pipeline")

        # seed
        for x in 1:10000
            insert(col, Dict("id" => repeat("a", 30), "value" => rand()*1000, "detail" => fill(Dict("id"=>rand(), "value"=>rand()), 4)))
        end

        # execute
        pipeline= [
           Dict("\$match" => Dict("value"=>Dict("\$gt"=>0))),
           Dict("\$project" => Dict("detail"=>1)),
           Dict("\$unwind" => "\$detail")
        ]
        options=Dict("allowDiskUse"=>true)
        arr = cursor_dicts(Mongo.mongo_aggregate(col, pipeline, options))

        # validate
        @fact length(arr) --> 40000

        # clean
        delete(col, Dict())
    end
end

facts("Mongo: bad host/port") do
    client = MongoClient("bad-host-name", 9999)
    collection = MongoCollection(client, "foo", "bar")
    @fact_throws insert(collection, ("foo" => "bar"))
end

facts("Query building helpers") do
    client = MongoClient()
    ppl = MongoCollection(client, "foo", "ppl")
    person(name, age) = insert(ppl, ("name" => name, "age" => age))
    person("Tim", 25)
    person("Jason", 21)
    person("Jim", 87)
    context("orderby") do
        @fact first(find(ppl, (query(), orderby("age" => -1))))["name"] --> "Jim"
        @fact first(find(ppl, (query(), orderby("age" => 1))))["name"] --> "Jason"
    end
    context("gt and lt") do
        @fact first(find(ppl, query("age" => lt(25))))["name"] --> "Jason"
        @fact first(find(ppl, query("age" => gt(50))))["name"] --> "Jim"
    end
    context("in and nin") do
        @fact first(find(ppl, query("age" => in([21]))))["name"] --> "Jason"
        @fact first(find(ppl, query("age" => nin([21,25]))))["name"] --> "Jim"
    end
    context("eq and ne") do
        @fact first(find(ppl, query("age" => eq(21))))["name"] --> "Jason"
        @fact first(find(ppl, query("age" => ne(87))))["name"] == "Jim" --> false
    end
    context("update with operator") do
        update(ppl, ("age" => 87), set("age" => 88))
        @fact first(find(ppl, query("name" => "Jim")))["age"] --> 88
    end
    delete(ppl, ())
end
