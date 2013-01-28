SUBCOMMAND = all

.PHONY: test $(SUBCOMMAND)

all: test

test:
	busted logic_test.lua