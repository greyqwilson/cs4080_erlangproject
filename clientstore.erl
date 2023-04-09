%This module stores user information
-module(clientstore).
-export([init/0]).

%entry into program
%make new dictionary and pass to init/1
init()->
    Cstorage = maps:new(),
    init(Cstorage).

init(Userstore) ->
    %add template entry to store
    Userstore_ = maps:put(username, password, Userstore),
    run(Userstore_).

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
            io:format("End of print_users~n")

    end.
        