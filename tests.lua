#!/usr/bin/env luajit

local posix = require("posix")

---[[
local assert = require"luassert"
--]]
--[[
-- NOTE: bug goes away (or becomes *very* rare; not yet observed IIRC)
local orig_assert = assert
local rawequal=rawequal
local assert = setmetatable({
    is_equal = function(a, b)
        orig_assert(rawequal(a, b))
    end,

    is_true = function(c)
        orig_assert(rawequal(c, true))
    end,
},
{
    __call = function(self, ...)
        orig_assert(...)
    end
})
--]]
--]=]

local collectgarbage = collectgarbage
local ipairs = ipairs

local ffi = require("ffi")
local jit = require("jit")

local select_dummy = ffi.load("select_dummy")
ffi.cdef[[
struct timeval;
int select_dummy(int nfds, fd_set *readfds, fd_set *writefds,
                 fd_set *exceptfds, struct timeval *timeout);
]]
local os = require("os")

local io = require("io")
local table = require("table")
local tostring=tostring

----------

local function print(...)
    local t = { ... }
    local strings = {}

    for i=1,#t do
        strings[i] = tostring(t[i])
    end

    local str = table.concat(strings, '\t')
    io.stderr:write(str..'\n')
end

-- ==========

        local MaxFdToTest = 65
        local FdsToTest = { 7, 8+1, 16+2, 24+3, 31, 32, 33, 63, 64, MaxFdToTest }

        local fdSet = posix.fd_set_t()
        local fds = {}
local curFd=3
        repeat
            local i = curFd
curFd=curFd+1
            assert(i >= 0 and i <= FdsToTest[#fds + 1])
            local fd = i

            if (i == FdsToTest[#fds + 1]) then
                fds[#fds + 1] = fd
                fdSet:set(i)
            end
        until (i == FdsToTest[#FdsToTest])

        assert(#fds == #FdsToTest)

        local IsFdTested = {}
        for _, i in ipairs(FdsToTest) do
            IsFdTested[i] = true
        end

        for i = 0, MaxFdToTest+1 do
            assert.is_equal(fdSet:isSet(i), IsFdTested[i] or false)
        end

        local function getBitsSetCount()
            local setBitsCount = 0
            for i = 0, MaxFdToTest + 1 do
                if (fdSet:isSet(i)) then
                    setBitsCount = setBitsCount + 1
                    assert.is_true(IsFdTested[i])
                end
            end
            return setBitsCount
        end
local ii=0
        repeat
            local fdReadyCount = select_dummy.select_dummy(MaxFdToTest + 1, fdSet, nil, nil, nil)
            assert.is_equal(fdReadyCount, #fds)
if (getBitsSetCount() ~= fdReadyCount) then
-- NOTE: the really odd one is when they differ:
-- (but can also have equal but < 10)
local t = {getBitsSetCount(), getBitsSetCount(), getBitsSetCount(), getBitsSetCount(), getBitsSetCount()}
if (not (t[1]==10 and t[2]==10 and t[3]==10 and t[4]==10 and t[5]==10)) then
    local v=t[1]
    local isReallyOdd = (t[2]~=v or t[3]~=v or t[4]~=v or t[5]~=v)

    print(t[1], t[2], t[3], t[4], t[5])

    if (not isReallyOdd) then
        io.stdout:write('This is the dump for "only" the "slightly" odd case!\n')
    end
    os.exit(isReallyOdd and 124 or 123)
end
end
ii=ii+1
            assert.is_equal(getBitsSetCount(), fdReadyCount)

            -- Exercise fdSet:clear()
            fdSet:clear(fds[#fds])
            fds[#fds] = nil
        until (#fds == 0)

-- ==========
