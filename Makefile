
.PHONY: test test-loop

define do_test =
  $(SHELL) ./run_tests.sh
endef

test: libselect_dummy.so
	$(do_test)

TEST_LOOP_COUNT ?= 2000
test-loop: test
	@echo "INFO: Repeating for a total of $(TEST_LOOP_COUNT) runs."
	@i=1; while test $$i -lt $(TEST_LOOP_COUNT); do i=$$((i+1)); $(do_test); done

opt_warn_flags := -O2
opt_warn_flags += -Werror -Wall -Wextra -pedantic
lib_flags := -shared -fPIC
cflags := -std=c99 $(opt_warn_flags) $(lib_flags)

libselect_dummy.so: select_dummy.c
	$(CC) $(cflags) $< -o $@
