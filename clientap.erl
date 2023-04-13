-module(clientap).
-export([init/2]).

%pass clientstore into here to link
init(Clientstorage, Warehouse) ->
    run(Clientstorage, Warehouse).

run(Clientstorage, Warehouse) ->
    receive
        
        % ~~~ (*)??? --> self <--> ClientStore
        {From, new_account, {User, Pass}} ->
            %Send to clientstore to request new account
            Clientstorage ! {self(), new, {User, Pass}},
            io:format("Sent message to Cstorage. Awaiting reply...~n"),
            receive 
                {_, new_acct_made} ->
                    io:format("New account made for ~s!~n", [User]),
                    %Tell warehouse to create a map for user's storage
                    Warehouse ! {self(), init_acct, User},
                    From ! {self(), acct_made};
                    
                _ ->
                    io:format("Something went wrong making account!~n")
            end,
            run(Clientstorage, Warehouse);


        % ~~~ (*)??? --> self: <--> ClientUser, --> Warehouse
        {From, put_data, {User, Pass}, Data_name, Data} ->
            Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    %talk to warehouse
                    Warehouse ! {self(), put_data, User, Data_name, Data},
                    io:format("Sent to warehouse!~n");
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,
            From ! {self(), done},
            io:format("End of put_data in clientap~n"),
            run(Clientstorage, Warehouse);
        
        % ~~~ (*)??? --> self: <--> ClientStore, --> Warehouse
        {From, remove_data, {User, Pass}, Data_name} ->
            Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    %talk to warehouse
                    Warehouse ! {self(), remove_data, User, Data_name},
                    io:format("Sent to warehouse!~n");
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,
            From ! {self(), done},
            io:format("End of remove_data in clientap~n"),
            run(Clientstorage, Warehouse);
        
        {From, update_data, {User, Pass}, Data_name, Data} ->
            Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    %talk to warehouse
                    Warehouse ! {self(), update_data, User, Data_name, Data},
                    io:format("Sent to warehouse!~n");
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,
            From ! {self(), done},
            io:format("End of update_data in clientap~n"),
            run(Clientstorage, Warehouse);

        {From, view_collection, {User, Pass}} ->
            Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    %talk to warehouse
                    Warehouse ! {self(), view_collection, User},
                    io:format("Sent to warehouse!~n");
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,
            From ! {self(), done},
            io:format("End of print_collection in clientap~n"),
            run(Clientstorage, Warehouse);

        % (*)ClientUser --> self
        {From, peek_data, {User, Pass}, Data_name} ->
            Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    Warehouse ! {self(), peek_data, User, Data_name};
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,
            run(Clientstorage, Warehouse);
        

        % (*)ClientUser --> self
        {From, login, {User, Pass}} ->
            Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    From ! {self(), welcome};
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end,
            run(Clientstorage, Warehouse);

            
        {'EXIT', Pid, Reason} ->
            io:format("Got EXIT from ~p with reason: ~w~nClosing ~p~n", [Pid, Reason, self()])

    end.


handle_verify(User, Pass, Clientstorage, Goodmsg, Sendto) ->
    Clientstorage ! {self(), verify, {User, Pass}},
            receive
                {_, goodpass} ->
                    Sendto ! Goodmsg;
                
                {_, badpass} ->
                    %spit out error
                    io:format("Password mismatch~n");
                
                {_, badkey} ->
                    %spit out error
                    io:format("Unknown account ~s~n", [User])
            end.
