#!/bin/sh

d=`pwd`
LUA_PATH="$d/?/init.lua;$d/?.lua"

export LUA_PATH

# weird bug: -O2 -> -O3
luajit -O3 "$d/tests.lua" "$@"
