#!/bin/sh

d=`pwd`
LUA_PATH="$d/?/init.lua;$d/?.lua"

export LUA_PATH

# weird bug: happens with -O3, but not with -O2
luajit -O3 "$d/tests.lua" "$@"
