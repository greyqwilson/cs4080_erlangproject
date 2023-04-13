%This module stores user information
-module(clientstore).
-export([init/0]).

%entry into program
%make new dictionary and pass to init/1
init()->
    %add template entry to store
    Cstorage = maps:put(username, password, maps:new()),
    init(Cstorage).

init(Userstore) ->
    %Ensure supervisor gets link to list of users
    receive
        {From, sv_givelist} ->
            From ! {self(), sv_listgive, Userstore},
            run(Userstore)
    end.

run(Userstore) ->
    receive

        % ~~~ (*)ClientAP <--> self
        %Make a new account 
        %(--TODO: Check if already exists --)
        {From, new, {User, Pass}} ->
            Userstore_ = maps:put(User, Pass, Userstore),
            From ! {self(), new_acct_made},
            run(Userstore_);

        % ~~~ (*)ClientAP <--> self
        %Verify account exists and password correct
        {From, verify, {User, Pass}}  ->
            case maps:find(User, Userstore) of
                {ok, Value} -> 
                    if Value =:= Pass -> From ! {self(), goodpass};
                        true -> From ! {self(), badpass}
                    end;
                error -> From ! {self(), badkey}
            end,
            run(Userstore);

        % ~~~ (*) Supervisor --> self
        {From, print_users} ->
            %use function
            io:format("End of print_users~n");

        
        {'EXIT', Pid, Reason} ->
            io:format("Got EXIT from ~p with reason: ~w~nClosing ~p~n", [Pid, Reason, self()])

    end.
        