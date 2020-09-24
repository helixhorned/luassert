local ffi = require("ffi")
local C = ffi.C

local bit = require("bit")

local assert = assert
local type = type

----------

local api = {
    O = { RDONLY = 0 }
}

local function checktype(v, _1, t, _2)
    assert(type(v) == t)
end
local check = assert

-- Baked fd_set (x86_64)
--
-- NOTE: 'man 2 select' says:
--  "The Linux kernel imposes no fixed limit, but the glibc implementation makes fd_set a
--   fixed-size type, with FD_SETSIZE defined as 1024, and the FD_*() macros operating
--   according to that limit."
--
-- (64 * 16 == 1024)
ffi.cdef[[
typedef
struct { uint64_t v_[16]; }
fd_set;

struct timeval;
]]

local uint32_t = ffi.typeof("uint32_t")
local fd_set_t = ffi.typeof("fd_set")

local fd_mask_t = ffi.typeof(
    ({ [4] = uint32_t, [8] = "uint64_t" })[ffi.alignof(fd_set_t)]
)
assert(fd_set_t{{-1}}.v_[0] == fd_mask_t(-1), "inconsistent fd_mask")

local FD_SETSIZE = 8 * ffi.sizeof(fd_set_t)
local FD_MASK_BIT_COUNT = 8 * ffi.sizeof(fd_mask_t)

local function checkSetFd(fd)
    checktype(fd, 1, "number", 4)
    check(fd >= 0 and fd < FD_SETSIZE, "file descriptor value is too large", 3)
end

api.fd_set_t = ffi.metatype(fd_set_t, { __index = {
    set = function(self, fd)
        local maskIdx, theBit = self:maskIdxAndBit(fd)
        self.v_[maskIdx] = bit.bor(self.v_[maskIdx], theBit)
    end,

    clear = function(self, fd)
        local maskIdx, theBit = self:maskIdxAndBit(fd)
        self.v_[maskIdx] = bit.band(self.v_[maskIdx], bit.bnot(theBit))
    end,

    isSet = function(self, fd)
        local maskIdx, theBit = self:maskIdxAndBit(fd)
        return (bit.band(self.v_[maskIdx], theBit) ~= 0)
    end,

    -- private:
    maskIdxAndBit = function(self, fd)
        checkSetFd(fd)
        local maskIdx = uint32_t(fd / FD_MASK_BIT_COUNT)
        local theBit = bit.lshift(1ULL, fd % FD_MASK_BIT_COUNT)
        return maskIdx, theBit
    end
}})

-- Done!
return api
