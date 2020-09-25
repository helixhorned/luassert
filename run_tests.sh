#!/bin/sh

d=`pwd`
LUA_PATH="$d/?/init.lua;$d/?.lua"

export LUA_PATH
export LD_LIBRARY_PATH="$d"

# With LuaJIT from Ubuntu 20.04 repo,
#  LuaJIT 2.1.0-beta3 -- Copyright (C) 2005-2017 Mike Pall.
# bug does not occur.

loop_count=${TEST_LOOP_COUNT:=1}
if [ $loop_count -gt 1 ]; then
    echo "INFO: Repeating for a total of $loop_count runs."
fi

# weird bug: happens with -O3, but not with -O2
i=0;
while [ $i -lt $loop_count ]; do
    i=$((i+1));
    luajit -O3 "$d/tests.lua" "$@"
done
