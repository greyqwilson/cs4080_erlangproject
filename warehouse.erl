-module(warehouse).
-export([init/0]).

%pass empty list and begin main loop
init() ->
    
    %Make at least one storage container
    First_SC = spawn_link(storage_container, init, []),
    register(first_sc, First_SC),
    init([First_SC], 1).

init(Whstore, N_storages) ->
    %Ensure supervisor gets link to list of storage containers
    receive
        {From, sv_givelist} ->
            From ! {self(), sv_listgive, Whstore},
            run(Whstore, N_storages)

    end.

%whstore is a list of storage_container's
run(Whstore, N_storages) ->
    process_flag(trap_exit, true),
    receive
        % ~~~ (*)??? --> self
        %Make a storage container
        {From, construct_st, Name}->
            %sync data with rest of containers
            H = hd(Whstore),
            New_SC = spawn_link(storage_container, init, []),
            register(Name, New_SC),
            H ! {New_SC, mget_storage}, 
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
        
        {From, peek_data, User, Data_name} ->
            hd(Whstore) ! {self(), peek_data, User, Data_name},
            run(Whstore, N_storages);
        
        {'EXIT', Pid, Reason} ->
            io:format("Got EXIT from ~p with reason: ~w~n", [Pid, Reason]),
            %Remove dead storage container from our list
            Whstore_ = lists:delete(Pid, Whstore),
            %Get the PID of the head of the list (assuming the list isn't out of storage_containers)
            H = hd(Whstore),
            %Make a new one and copy next storage container over
            New_SC = spawn_link(storage_container, init, []),
            H ! {New_SC, mget_storage},
            run([New_SC|Whstore_], N_storages);

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
    ok;
    %io:format("Messages sent~n");

mass_message(Message, [H|Rest], N) ->
    H ! Message,
    %io:format("~w left to send!~n", [N-1]),
    mass_message(Message, Rest, N-1).
