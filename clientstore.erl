%This module stores user information
-module(clientstore).
-export([init/0]).

%entry into program
init()->
    Cstorage = maps:new(),
    init(Cstorage).

init(Userstore) ->
    %add template entry to store
    maps:put(username, password, Userstore),
    run(Userstore).

run(Userstore) ->
    receive
        {From, {new, {User, Pass}}} ->
            new_acct({User, Pass}, Userstore),
            From ! {self(), {new_acct_made}}
    end,
    run(Userstore).
            

new_acct({Username, Password}, Userstore) ->
    maps:put(Username, Password, Userstore).