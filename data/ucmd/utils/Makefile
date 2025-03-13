#
# 'make'        build executable file 'main'
# 'make clean'  removes all generated files and executable files
#

# define source directory
SRCDIR		:= ../ucmd_src

# define test directory
DESTDIR := ../ucmd_dest

UCMD := ucmd

RM  := rm -f

MD	:= mkdir -p

.PHONY: clean

all: hello regex

hello:
	python3 range_converter.py $(SRCDIR)/uart_hello_world.ucmd $(DESTDIR)/_uart_hello_world.ucmd
	./$(UCMD) $(DESTDIR)/_uart_hello_world.ucmd $@ $(DESTDIR)/uart_hello_world.v $(DESTDIR)/uart_hello_world.mcmem $(DESTDIR)/uart_hello_world.adrmem $(DESTDIR)/uart_hello_world.dot
	dot -Tsvg $(DESTDIR)/uart_hello_world.dot -o $(DESTDIR)/uart_hello_world.svg
	$(RM) $(DESTDIR)/_uart_hello_world.ucmd
	@echo Выполнение сборки 'run: uart' завершено!

regex:
	python3 range_converter.py $(SRCDIR)/uart_regex.ucmd $(DESTDIR)/_uart_regex.ucmd
	./$(UCMD) $(DESTDIR)/_uart_regex.ucmd $@ $(DESTDIR)/uart_regex.v $(DESTDIR)/uart_regex.mcmem $(DESTDIR)/uart_regex.adrmem $(DESTDIR)/uart_regex.dot
	dot -Tsvg $(DESTDIR)/uart_regex.dot -o $(DESTDIR)/uart_regex.svg
	$(RM) $(DESTDIR)/_uart_hello_world.ucmd
	@echo Выполнение сборки 'run: regex' завершено!

clean:
	$(RM) $(DESTDIR)/*
	@echo Cleanup complete!
