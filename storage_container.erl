-module(storage_container).
-export([init/0, init/1]).

%make map to store data and begin main loop, run
init() ->
    %Map of all accounts and their associated storage {owner, user's mapped storage}
    Storage = maps:new(),
    Storage_ = maps:put(owner, {datamap_, goes_, here_}, Storage),
    run(Storage_).

init(Storage) ->
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
            Userdata = maps:get(Owner, Storage),
            case maps:is_key(Data_name, Userdata) of
                true -> 
                    Userdata_ = maps:remove(Data_name, Userdata),
                    Storage_ = maps:put(Owner, Userdata_, Storage),
                    io:format("Removed ~s from ~s's storage!~n", [Data_name, Owner]),
                    run(Storage_);
                false ->
                    io:format("Failed to locate existing data: ~s~n", [Data_name]),
                    run(Storage)
            end;

        % ~~~ (**)Warehouse --> self
        {From, update_data, Owner, Data_name, Data} ->
            Userdata = maps:get(Owner, Storage),
            case maps:is_key(Data_name, Userdata) of
                true -> 
                    Userdata_ = maps:put(Data_name, Data, Userdata),
                    Storage_ = maps:put(Owner, Userdata_, Storage),
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
            io:format("~w~n", [maps:get(Owner, Storage)]),
            run(Storage);

        %Initialize a new account
        % ~~~ (*)Warehouse <--> self
        {From, new_acct_store, User} ->
            New_acct_store = maps:put(data_name, data_here, maps:new()),
            Storage_ = maps:put(User, New_acct_store, Storage),
            %From ! {self(), acct_store_initialized},
            run(Storage_);

        % ~~~ (*)Warehouse --> self
        {From, peek_data, User, Data_name} ->
            Userdata = maps:get(User, Storage),
            io:format("~s: ~w~n", [Data_name, maps:get(Data_name, Userdata)]),
            run(Storage);

        %Pairs with mget_storage where Storage_container A transfers their Storage to Storage_container B.
        % ~~~ (*)Storage_container A --> Storage_container B
        {From, merge_storage, Otherstorage} ->
            Storage_ = maps:merge(Otherstorage, Storage),
            io:format("~p: Merged with my pal ~p~n", [self(), From]),
            run(Storage_);

        %Pairs with merge_storage where Storage_container A transfers their Storage to Storage_container B
        % ~~~ (*)Warehouse --> Storage_container A --> Storage_container B
        {From, mget_storage} ->
            From ! {self(), merge_storage, Storage},
            run(Storage);

        {'EXIT', Pid, Reason} ->
            io:format("Got EXIT from ~p with reason: ~w~nClosing ~p~n", [Pid, Reason, self()])
    end.