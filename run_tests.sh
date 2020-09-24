#!/bin/sh

d=`pwd`
LUA_PATH="$d/?/init.lua;$d/?.lua"

export LUA_PATH

# With LuaJIT from Ubuntu 20.04 repo,
#  LuaJIT 2.1.0-beta3 -- Copyright (C) 2005-2017 Mike Pall.
# bug does not occur.

# weird bug: happens with -O3, but not with -O2
luajit -O3 "$d/tests.lua" "$@"
