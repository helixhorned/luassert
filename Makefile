
.PHONY: test test-loop

define do_test =
  $(SHELL) ./run_tests.sh
endef

test:
	$(do_test)

TEST_LOOP_COUNT ?= 10
test-loop: test
	@echo "INFO: Repeating for a total of $(TEST_LOOP_COUNT) runs."
	@i=1; while test $$i -lt $(TEST_LOOP_COUNT); do i=$$((i+1)); $(do_test); done
