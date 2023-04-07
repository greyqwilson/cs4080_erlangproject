-module(warehouse).
-export([init/0]).

%pass empty list and begin main loop
init() ->
    run([], 0).

%whstore is a list of storage_container's
run(Whstore, N_storages) ->
    receive

        % ~~~ Warehouse <--> Storage_Container
        %Make a storage container
        {From, {construct_st, Name}}->
            %append name to store
            New_SC = {spawn(storage_container, init, []), Name},
            io:format("Made storage ~s.", [Name]),
            run([New_SC|Whstore], N_storages + 1);

        % ~~~ ClientAP --> Warehouse <--> Storage_Container
        %Initialize a user's account after it was made
        {From, init_acct, User} ->
            %all_sc_map(fun maps:put(User, init, Whstore), Whstore)
            mass_message({self(), new_acct_store, User}, Whstore);
        
        % ~~~ ClientAP --> Warehouse <--> Storage_Container
        %Print entirety of a user's collection
        {From, {print_collection}} ->
            print(Whstore, N_storages),
            io:format("unimplemented");

        {From, {put, Owner, Data}} ->
            io:format("unimplemented");
        
        {From, {remove, Owner, {Data}}} ->
            io:format("unimplemented");
        
        {From, {update, Owner, {Data}}} ->
            io:format("unimplemented");

        _ ->
            io:format("Unrecognized message.~n")
        
    end,
    run(Whstore, N_storages).

%puts into each locker
put_in_locker({Data}) ->
    io:format("unimplented").

print([], 0) ->
    io:format("End of collection~n");

print([H|Whstore], N) ->
    io:format("~s~n", [H]),
    print([Whstore|H], N-1).

%Mass message each storage container in warehouse
mass_message(_, []) ->
    io:format("Messages sent");

mass_message(Message, [H|Whstore]) ->
    H ! Message,
    mass_message(Message, Whstore).