local assert = require('luassert.assert')

assert._COPYRIGHT   = "Copyright (c) 2018 Olivine Labs, LLC."
assert._DESCRIPTION = "Extends Lua's built-in assertions to provide additional tests and the ability to create your own."
assert._VERSION     = "Luassert 1.8.0"

-- load basic asserts
require('luassert.assertions')
require('luassert.modifiers')
--require('luassert.array')
--require('luassert.matchers')
--require('luassert.formatters')

-- load default language
-- NOTE: commenting out -> less frequent occurrence of the bug.
--  (one in a few 1000x-repeat runs, otherwise a few times each 1000x repeat run)
require('luassert.languages.en')

return assert
