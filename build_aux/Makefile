#include ../Makefile

SHELL = /bin/bash
VIM = vim
# Script
VIM_SCRIPT = ./correct.vim
# Test files
TEST_IN = ./tests/base.vim-correct.txt
TEST_OUT = /tmp/base.vim-correct.txt
TEST_OK = ./tests/base.vim-correct.ok
# Log file
LOG = ./tests/base.vim-correct.log

help:
	@echo "TARGETS"
	@echo "    test-vim-correct"
	@echo
	@echo "Script used for typographic correction:  $(VIM_SCRIPT)"
	@echo "Test files used: $(TEST_IN), $(TEST_OK), $(TEST_OUT)"

test-vim-correct: $(VIM_SCRIPT) $(TEST_IN)
	cp $(TEST_IN) $(TEST_OUT)
	$(VIM) -c ":e $(TEST_OUT) | :source $(VIM_SCRIPT)"
	@echo ":: COMPARING CORRECT VERSTION TO TEST OUTPUT"
	@echo ":: WILL TRIGGER AN ERROR IF NOT 100% MATCHING"
	diff $(TEST_OUT) $(TEST_OK) > $(LOG)
	@echo ":: SUCCESS!"

clean-test:
	touch $(TEST_OUT) && rm $(TEST_OUT)
