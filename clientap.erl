-module(clientap).
-export([init/1]).

%pass clientstore into here to link
init(Cstorage) ->
    run(Cstorage).

run(Cstorage) ->
    receive
        {From, {new_account, {User, Pass}}} ->
            %Send to clientstore to request new account
            Cstorage ! {self(), {new, {User, Pass}}},
            io:format("Sent message to Cstorage. Awaiting reply~n"),
            receive 
                {FromCstore, {new_acct_made}} ->
                    io:format("New account made!~n");
                
                {FromCstore, {_}} ->
                    io:format("Something went wrong making account~n")
            end;

        {From, {add_data, {User, Pass}, {Data}}} ->
            io:format("unimplemented~n");
        
        {From, {remove_data, {User, Pass}, {Key}}} ->
            io:format("unimplemented~n");
        
        {From, {update_data, {User, Pass}, {Key}, {Data}}} ->
            io:format("unimplemented~n")
    end,
    run(Cstorage).


