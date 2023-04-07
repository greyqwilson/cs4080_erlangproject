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
    maps:put(username, password, Userstore),
    run(Userstore).

run(Userstore) ->
    receive

        %Make a new account 
        %(--TODO: Check if already exists --)
        {From, {new, {User, Pass}}} ->
            new_acct({User, Pass}, Userstore),
            From ! {self(), new_acct_made};

        %Verify account exists and password correct
        {From, {verify, {User, Pass}}}  ->
            case maps:find(User, Userstore) of
                {ok, Value} -> 
                    if Value =:= Pass -> From ! {self(), goodpass};
                        true -> From ! {self(), badpass}
                    end;
                error -> From ! {self(), badkey}
            end

    end,
    run(Userstore).
            

new_acct({Username, Password}, Userstore) ->
    maps:put(Username, Password, Userstore).