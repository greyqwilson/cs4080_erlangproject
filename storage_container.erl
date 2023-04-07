-module(storage_container).
-export([init/0]).

%make map to store data and begin main loop, run
init() ->
    Storage = maps:new(),
    maps:put(id, {owner, {data}}, Storage),
    run(Storage).

run(Storage) ->
    receive
        {From, {put, {User, Pass}, Owner, {Data}}} ->
            maps:put(id_here, {Data}, Storage),
            io:format("unimplemented");
        
        {From, {remove, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented");
        
        {From, {update, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented")
        
    end,
    run(Storage).
