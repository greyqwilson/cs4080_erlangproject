-module(warehouse).
-export([init/0]).

%pass empty list and begin main loop
init() ->
    run([], 0).

%whstore is a list of storage_container's
run(Whstore, N_storages) ->
    receive
        {From, {construct_st, Name}}->
            %append name to store
            New_SC = {spawn(storage_container, init, []), Name},
            io:format("Made storage ~s. Warehouse is now ~w unit(s) large~n", [Name, N_storages]),
            run([New_SC|Whstore], N_storages + 1);

        {From, {print_collection}} ->
            io:format("unimplemented");

        {From, {put, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented");
        
        {From, {remove, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented");
        
        {From, {update, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented");

        {From, _} ->
            io:format("Unrecognized message.~n");

        _ ->
            io:format("Unrecognized message.~n")
        
    end.

%puts into each locker
put_in_locker({Data}) ->
    io:format("unimplented").

print([H|Whstore], N) ->
    io:format("~s~n", [H]),
    print([Whstore|H], N-1).