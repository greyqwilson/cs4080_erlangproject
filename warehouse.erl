-module(warehouse).
-export([init/0]).

%pass empty list and begin main loop
init() ->
    run([], 0).

%whstore is a list of storage_container's
run(Whstore, N_storages) ->
    receive

        % ~~~ (*)??? --> self
        %Make a storage container
        {From, construct_st, Name}->
            %append name to store
            % should these be identifiable by names?
            New_SC = spawn(storage_container, init, []),
            io:format("Made storage ~s with PID: ~w.~n", [Name, New_SC]),
            run([New_SC|Whstore] , N_storages + 1);

        % ~~~ (*)ClientAP --> self ->-> Storage_Container(s)
        %Initialize a user's account after it was made
        {From, init_acct, User} ->
            %all_sc_map(fun maps:put(User, init, Whstore), Whstore)
            mass_message({self(), new_acct_store, User}, Whstore, N_storages),
            run(Whstore, N_storages);
        
        % ~~~ (*)self
        %Print entirety of the warehouse collection
        {From, print_collection} ->
            print(Whstore, N_storages),
            io:format("End of print_collection in warehouse~n"),
            run(Whstore, N_storages);

        % ~~~ (*)ClientAP --> self ->-> Storage_Container(s)
        {From, put_data, User, Data_name, Data} ->
            mass_message({self(), put_data, User, Data_name, Data}, Whstore, N_storages),
            io:format("End of put in warehouse~n"),
            run(Whstore, N_storages);
        
        % ~~~ (*)ClientAP --> self ->-> Storage_Container(s)
        {From, remove_data, User, Data_name} ->
            mass_message({self(), remove_data, User, Data_name}, Whstore, N_storages),
            io:format("End of remove in warehouse~n"),
            run(Whstore, N_storages);
        
        % ~~~ (*)ClientAP --> self ->-> Storage_Container(s)
        {From, update_data, User, Data_name, Data} ->
            mass_message({self(), update_data, User, Data_name, Data}, Whstore, N_storages),
            io:format("End of update in warehouse~n"),
            run(Whstore, N_storages);
        
        {From, view_collection, User} ->
            mass_message({self(), view_collection, User}, Whstore, N_storages),
            run(Whstore, N_storages);

        _ ->
            io:format("Unrecognized message.~n"),
            run(Whstore, N_storages)
        
    end.

print(_, 0) ->
    io:format("End of collection~n"),
    ok;

print([H|T], N) ->
    io:format("Storage container ~w: ~w~n", [N, H]),
    print(T, N-1).

%Mass message each storage container in warehouse
mass_message(_, [], 0) ->
    io:format("Messages sent~n");

mass_message(Message, [H|Rest], N) ->
    H ! Message,
    io:format("~w left to send!~n", [N-1]),
    mass_message(Message, Rest, N-1).