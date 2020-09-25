
.PHONY: test test-loop

do_test := $(SHELL) ./run_tests.sh

test: libselect_dummy.so
	@$(do_test)

test-loop:
	@TEST_LOOP_COUNT=2000 $(do_test)

opt_warn_flags := -O2
opt_warn_flags += -Werror -Wall -Wextra -pedantic
lib_flags := -shared -fPIC
cflags := -std=c99 $(opt_warn_flags) $(lib_flags)

libselect_dummy.so: select_dummy.c
	$(CC) $(cflags) $< -o $@
