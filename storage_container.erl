-module(storage_container).
-export([init/0]).

%make map to store data and begin main loop, run
init() ->
    %Map of all accounts and their associated storage {owner, user's mapped storage}
    Storage = maps:new(),
    maps:put(owner, {datamap_, goes_, here_}, Storage),
    run(Storage).

run(Storage) ->
    receive
        {From, {put, {User, Pass}, Owner, {Data}}} ->
            Storage_ = maps:put(id_here, {Data}, Storage),
            run(Storage_);
        
        {From, {remove, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented");
        
        {From, {update, {User, Pass}, Owner, {Data}}} ->
            io:format("unimplemented");

        {From, {view_collection, {User, Pass}}} ->
            io:format("unimplemeted");

        %Initialize a new account
        % ~~~ Warehouse <--> Storage_Container
        {From, new_acct_store, User} ->
            New_acct_store = maps:new(),
            Storage_ = maps:put(User, New_acct_store, Storage),
            From ! {self(), acct_store_initialized},
            run(Storage_)

    end,
    run(Storage).