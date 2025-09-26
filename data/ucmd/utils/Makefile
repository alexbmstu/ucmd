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

# define HDL sources
UCMD_SRCS := $(wildcard $(SRCDIR)/*.ucmd)
UCMD_OBJS := $(patsubst %.ucmd,%.v,$(notdir $(UCMD_SRCS)))

.PHONY: clean

all: $(UCMD_OBJS)

%.v: $(SRCDIR)/%.ucmd

	@echo "\n===================================================================\n"
	@echo "\tТрансляция микрокода $@!"
	@echo "\n===================================================================\n"
	./$(UCMD) $(SRCDIR)/$(basename $@).ucmd $(basename $@) $(DESTDIR)/$(basename $@).v $(DESTDIR)/$(basename $@).mcmem $(DESTDIR)/$(basename $@).adrmem $(DESTDIR)/$(basename $@).dot -t=./mcprog_template.v
	@echo "\nГенерация графа переходов $@!\n"
	dot -Tsvg $(DESTDIR)/$(basename $@).dot -o $(DESTDIR)/$(basename $@).svg
	@echo "\nВыполнение сборки $@ завершено!\n"


clean:
	$(RM) $(DESTDIR)/*
	@echo Cleanup complete!
