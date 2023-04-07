-module(clientap).
-export([init/2]).

%pass clientstore into here to link
init(Cstorage, Warehouse) ->
    run(Cstorage, Warehouse).

run(Cstorage, Warehouse) ->
    receive
        
        % ~~~ ClientAP <--> ClientStore interactions
        {From, {new_account, {User, Pass}}} ->
            %Send to clientstore to request new account
            Cstorage ! {self(), {new, {User, Pass}}},
            io:format("Sent message to Cstorage. Awaiting reply~n"),
            receive 
                {_, new_acct_made} ->
                    io:format("New account made!~n"),
                    %Tell warehouse to create a map for user's storage
                    Warehouse ! {self(), init_acct},
                    From ! {self(), acct_made};

                _ ->
                    io:format("Something went wrong making account!~n")
            end;

        % ~~~ ClientAP <--> ClientUser interactions

        {From, {add_data, {User, Pass}, {Data}}} ->
            Cstorage ! {self(), {verify, {User, Pass}}},
            receive
                {_, goodpass} ->
                    %talk to warehouse
                    Warehouse ! {self(), {put, {User, Data}}},
                    io:format("unimplemented~n");
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,

            io:format("unimplemented~n");
        
        {From, {remove_data, {User, Pass}, {Key}}} ->
            io:format("unimplemented~n");
        
        {From, {update_data, {User, Pass}, {Key}, {Data}}} ->
            io:format("unimplemented~n");

        {From, {print_collection, {User, Pass}}} ->
            io:format("unimplemented~n")
    end,
    run(Cstorage, Warehouse).


