-module(storage_container).
-export([init/0]).

%make map to store data and begin main loop, run
init() ->
    %Map of all accounts and their associated storage {owner, user's mapped storage}
    Storage = maps:new(),
    Storage_ = maps:put(owner, {datamap_, goes_, here_}, Storage),
    run(Storage_).

run(Storage) ->
    receive

        % ~~~ (**)Warehouse --> self
        {From, put_data, Owner, Data_name, Data} ->
            %access Owner's mapstore, put data in
            Usermapstore = maps:put(Data_name, Data, maps:get(Owner, Storage)),
            io:format("Usermapstore: ~w~n", [Usermapstore]),
            Storage_ = maps:put(Owner, Usermapstore, Storage),
            io:format("Added ~s to ~s's storage!~n", [Data_name, Owner]),
            run(Storage_);
        
        % ~~~ (**)Warehouse --> self
        {From, remove_data, Owner, Data_name} ->
            case maps:is_key(Data_name, Storage) of
                true -> 
                    Usermapstore = maps:remove(Data_name, maps:get(Owner, Storage)),
                    Storage_ = maps:put(Owner, Usermapstore, Storage),
                    io:format("Removed ~s from ~s's storage!~n", [Data_name, Owner]),
                    run(Storage_);
                false ->
                    io:format("Failed to locate existing data: ~s~n", [Data_name]),
                    run(Storage)
            end;

        % ~~~ (**)Warehouse --> self
        {From, update_data, Owner, Data_name, Data} ->
            case maps:is_key(Data_name, Storage) of
                true -> 
                    Usermapstore = maps:put(Data_name, Data, maps:get(Owner, Storage)),
                    Storage_ = maps:put(Owner, Usermapstore, Storage),
                    %Maybe show changed data here
                    io:format("Updated ~s from ~s's storage!~n", [Data_name, Owner]),
                    run(Storage_);
                false ->
                    io:format("Failed to locate existing data: ~s~n", [Data_name]),
                    run(Storage)
            end;

        % ~~~ (**)Warehouse --> self
        {From, view_collection, Owner} ->
            %From ! {self(), maps:get(Owner, Storage)},
            io:format("~w", [maps:get(Owner, Storage)]),
            run(Storage);

        %Initialize a new account
        % ~~~ (*)Warehouse <--> Storage_Container
        {From, new_acct_store, User} ->
            New_acct_store = maps:put(data_name, data_here, maps:new()),
            Storage_ = maps:put(User, New_acct_store, Storage),
            %From ! {self(), acct_store_initialized},
            run(Storage_)

    end.