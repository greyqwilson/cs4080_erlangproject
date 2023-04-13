-module(sv).
-export([init/0]).

init() ->
    process_flag(trap_exit, true),
    io:format("Starting warehouse~n"),
    Warehouse = spawn_link(warehouse, init, []),
    Warehouse ! {self(), sv_givelist},
    io:format("Waiting for response from Warehouse~n"),
    receive
        {FromWH, sv_listgive, Whstore} ->
            {ok, FromWH}

    end,
    register(warehouseN, Warehouse),

    io:format("Starting clientstore~n"),
    Clientstore = spawn_link(clientstore, init, []),
    Clientstore ! {self(), sv_givelist},
    io:format("Waiting for response from Clientstore~n"),
    receive
        {FromCS, sv_listgive, Cstorage} ->
            {ok, FromCS}

    end,
    register(clientstoreN, Clientstore),

    io:format("Starting clientap~n"),
    ClientAP = spawn_link(clientap, init, [Clientstore, Warehouse]),
    register(clientapN, ClientAP),
    Watchlist = #{Warehouse => wh, Clientstore => cs, ClientAP => cap},

    loop(Warehouse, Clientstore, ClientAP, Watchlist, Whstore, Cstorage).

loop(Warehouse, Clientstore, ClientAP, Watchlist, Wh_list_ref, Cs_list_ref) ->
    receive
        {'EXIT', Pid, normal} ->
            ok;
        {'EXIT', Pid, shutdown} ->
            exit(shutdown);

        %Something has gone wrong
        {'EXIT', Pid, _} ->
            %Figure out what crashed
            case maps:get(Pid, Watchlist) of
                wh ->
                    %restart warehouse
                    Warehouse = spawn_link(warehouse, run, [Wh_list_ref, length(Wh_list_ref)]),
                    Watchlist_ = maps:put(Warehouse, wh, maps:remove(Pid, Watchlist)),
                    loop(Warehouse, Clientstore, ClientAP, Watchlist_, Wh_list_ref, Cs_list_ref);

                cs ->
                    %restart clientstore
                    Clientstore = spawn_link(clientstore, run, [Cs_list_ref]),
                    Watchlist_ = maps:put(Clientstore, cs, maps:remove(Pid, Watchlist)),
                    loop(Warehouse, Clientstore, ClientAP, Watchlist_, Wh_list_ref, Cs_list_ref);

                cap ->
                    %restart clientap
                    %need to be able to give PID of clienstore and warehouse
                    ClientAP = spawn_link(clientap, run, [clientstoreN, warehouseN]),
                    Watchlist_ = maps:put(ClientAP, cap, maps:remove(Pid, Watchlist)),
                    io:format("Welcome back to the land of the living ClientAP~n"),
                    loop(Warehouse, Clientstore, ClientAP, Watchlist_, Wh_list_ref, Cs_list_ref)
            end
    end.
    


% %for starting modules
% start(Mod, Args) ->
%     %spawn myself and begin supervising
%     spawn(?MODULE, init, []).

% start_link(Mod, Args) ->
%     spawn_link(?MODULE, init, []).

% init({Mod, Args}) ->
%     process_flag(trap_exit, true),
%     loop({Mod, start_link, args}).

% loop({M,F,A}) ->
%     Pid = apply(M,F,A),
%     receive
%         {'EXIT', _From, shutdown} ->
%             exit(shutdown);
%         {'EXIT', Pid, Reason} ->
%             io:format("Process ~p exited for reason ~p~n", [Pid, Reason]),
%             loop({M,F,A})
        
%     end.