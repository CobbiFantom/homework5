-module(my_cache_test).

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

my_cache_test_() -> [
    ?_assert(my_cache:create(table) == new_table)
].

-endif.
