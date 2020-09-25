#!/bin/bash

opts=
if [ -n "$DUMPDIR" ]; then
    opts=-jdump
    if [ ! -d "$DUMPDIR" ]; then
        echo "ERROR: $DUMPDIR must be a directory." 1>&2
        exit 100
    elif [ ! -w "$DUMPDIR" ]; then
        echo "ERROR: $DUMPDIR must be writable." 1>&2
        exit 101
    fi
fi

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
    lsb=$((i&1))
    olsb=$(((i+1)&1))
    # COLORTERM: Make LuaJIT's jit/dump.lua always output ANSI-colored text.
    f="$DUMPDIR/out$lsb.log"
    of="$DUMPDIR/out$olsb.log"
    COLORTERM=1 luajit -O3 $opts "$d/tests.lua" "$@" > "$f"

    if [ $? -eq 124 ]; then
        bf="$DUMPDIR/bad.log"
        gf="$DUMPDIR/good.log"

        echo "INFO: encountered 'really odd' case:"
        mv "$f" "$bf"
        echo "      Its -jdump output can be found in: '$bf'."
        if [ -f "$of" ]; then
            mv "$of" "$gf"
            echo "      A reference -jdump for a good run: '$gf'."
        fi

        # Replace (0x)?[12 times hexbit] as these are most likely addresses.
        sedEcmds='s/\<(0x)?[0-9a-f]{12}\>/\1LIKELYADDRSS/g'
        sed -E "$sedEcmds" "$bf" > "$bf.norm"
        if [ -f "$gf" ]; then
            sed -E "$sedEcmds" "$gf" > "$gf.norm"
        fi

        exit 124
    fi

    i=$((i+1));
done
