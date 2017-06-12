using BinDeps

@BinDeps.setup

libmongoc = library_dependency(
    "libmongoc",
    aliases = ["libmongoc", "libmongoc-1.0"]
    )

provides(Sources, Dict(
    URI("http://github.com/mongodb/mongo-c-driver/releases/download/1.3.5/mongo-c-driver-1.3.5.tar.gz") => libmongoc
    ))

provides(
    BuildProcess,
    Autotools(libtarget = "libmongoc-1.3.la"),
    libmongoc,
    os = :Unix
    )
            
@static if is_apple()
    using Homebrew
    provides(Homebrew.HB, Dict("mongo-c-driver" => libmongoc))
end

@BinDeps.install Dict(:libmongoc => :libmongoc)
