-module(clientuser).

-compile(export_all).

%retrieve
grab(Key, Map) ->
    maps:get(Key, Map),
    Z = #{},
    Z#{Key=>a},
    X = maps:get(Key, Map, "not found").

%store

%delete

%update

