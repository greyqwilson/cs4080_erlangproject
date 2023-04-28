-module(clientuser).
-export([init/1]).

init(CAP_Pid) ->
    io:format("~~ Client Login ~~~n"),
    receive
        {From, login, {User, Pass}} ->
            CAP_Pid ! {self(), login, {User, Pass}},
            receive
                {FromCAP, welcome} ->
                    io:format("Successfully logged in! ~s~n", [User]),
                    run(CAP_Pid, {User, Pass});
                _ ->
                    io:format("Wrong username or password given.~n"),
                    init(CAP_Pid)
            end;

        {From, register, {User, Pass}} ->
            CAP_Pid ! {self(), new_account, {User, Pass}},
            receive
                {CAP_Pid, acct_made} ->
                    io:format("Account made for ~s~n", [User]),
                    init(CAP_Pid);

                _ ->
                    init(CAP_Pid)

            end;

        _ ->
            io:format("Unrecognized input! Try register or login!~n"),
            init(CAP_Pid)
    end.



run(CAP_Pid, {User, Pass}) ->

    receive
        %store
        {add, Data_name, Data} ->
            CAP_Pid ! {self(), put_data, {User, Pass}, Data_name, Data},
            run(CAP_Pid, {User, Pass});
        
        %delete
        {remove, Data_name} ->
            CAP_Pid ! {self(), remove_data, {User, Pass}, Data_name},
            run(CAP_Pid, {User, Pass});
        
        %update
        {update, Data_name, Data} ->
            CAP_Pid ! {self(), update_data, {User, Pass}, Data_name, Data},
            run(CAP_Pid, {User, Pass});

        {show_all} ->
            CAP_Pid ! {self(), view_collection, {User, Pass}},
            run(CAP_Pid, {User, Pass});

        %retrieve
        {show, Data_name} ->
            CAP_Pid ! {self(), peek_data, {User, Pass}, Data_name},
            run(CAP_Pid, {User, Pass});

        {logout} ->
            io:format("~s has logged out~n", [User]),
            init(CAP_Pid)
    end.
