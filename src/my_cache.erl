-module(my_cache).

-export([create/1]).
-export([insert/3]).
-export([insert/4]).
-export([lookup/2]).
-export([delete_obsolete/1]).

-include_lib("stdlib/include/ms_transform.hrl").

create(TableName) ->
    case ets:info(TableName) of
        undefined ->
            ets:new(TableName, [public, named_table]);
        _ ->
            already_exist
    end.

insert(TableName, Key, Value) ->
    case ets:info(TableName) of
        undefined ->
            undefined;
        _ ->
            ets:insert(TableName, {Key, Value})
    end.

insert(TableName, Key, Value, Timeout) ->
    case ets:info(TableName) of
        undefined ->
            undefined;
        _ ->
            ets:insert(TableName, {Key, Value, erlang:system_time(seconds) + Timeout})
    end.

lookup(TableName, Key) ->
    case ets:info(TableName) of
        undefined ->
            undefined;
        _ ->
            case ets:lookup(TableName, Key) of
                [] ->
                    undefined;
                [{_, Value, Timeout}] ->
                    case erlang:system_time(seconds)>= Timeout of
                        true ->
                            undefined;
                        false ->
                            Value
                    end;
                [{Key, Value}] ->
                    Value
            end
    end.

delete_obsolete(TableName) ->
    Now = erlang:system_time(seconds),
    Select = ets:fun2ms(fun({_, _, Timeout}) when Timeout < Now -> true end),
    try
        ets:select_delete(TableName,Select)
    of
        _ ->
            ok
    catch
        error:badarg ->
            {error, not_exists}
    end.
