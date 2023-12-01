
.PHONY: default
default: ncurses_example


.PHONY: help ## to show this help
help:
	@grep -E '^.PHONY:.*##' Makefile | sed 's/.PHONY: //g' | awk 'BEGIN {FS = " *## *"}; {printf "\033[33m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: ncurses_example ## to compile and run the ncurses example program
ncurses_example:
	rm -f ncurses_example ; ghc ncurses_example.hs
	./ncurses_example


.PHONY: clean ## delete compilation output and the executable
clean:
	rm -f ncurses_example.hi
	rm -f ncurses_example.o
	rm -f ncurses_example
