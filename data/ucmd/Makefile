#
# 'make'        build executable file 'main'
# 'make clean'  removes all .o and executable files
#
# define test directory
UCMD_EXAMPLE := ucmd_example
UCMD_UART := ucmd_uart
UCMD_REGEX := ucmd_regex

.PHONY: all


all: example uart regex
	@echo Executing 'all' complete!

example: 
	python3 range_converter.py ./$(UCMD_EXAMPLE)/example_fsm.ucmd ./$(UCMD_EXAMPLE)/_example_fsm.ucmd
	./ucmd ./$(UCMD_EXAMPLE)/_example_fsm.ucmd example ./$(UCMD_EXAMPLE)/mcprog_example.v ./$(UCMD_EXAMPLE)/example_fsm.mcmem ./$(UCMD_EXAMPLE)/example_fsm.adrmem ./$(UCMD_EXAMPLE)/example_fsm.dot
	dot -Tsvg ./$(UCMD_EXAMPLE)/example_fsm.dot -o ./$(UCMD_EXAMPLE)/example_fsm.svg
	@echo Выполнение сборки 'ucmd_example' завершено!


uart: 
	python3 range_converter.py ./$(UCMD_UART)/uart_hello_world.ucmd ./$(UCMD_UART)/_uart_hello_world.ucmd
	./ucmd ./$(UCMD_UART)/_uart_hello_world.ucmd example ./$(UCMD_UART)/uart_hello_world.v ./$(UCMD_UART)/uart_hello_world.mcmem ./$(UCMD_UART)/uart_hello_world.adrmem ./$(UCMD_UART)/uart_hello_world.dot
	dot -Tsvg ./$(UCMD_UART)/uart_hello_world.dot -o ./$(UCMD_UART)/uart_hello_world.svg
	@echo Выполнение сборки 'ucmd_uart' завершено!

regex: 
	python3 range_converter.py ./$(UCMD_REGEX)/uart_regex.ucmd ./$(UCMD_REGEX)/_uart_regex.ucmd
	./ucmd ./$(UCMD_REGEX)/_uart_regex.ucmd example ./$(UCMD_REGEX)/uart_regex.v ./$(UCMD_REGEX)/uart_regex.mcmem ./$(UCMD_REGEX)/uart_regex.adrmem ./$(UCMD_REGEX)/uart_regex.dot
	dot -Tsvg ./$(UCMD_REGEX)/uart_regex.dot -o ./$(UCMD_REGEX)/uart_regex.svg
	@echo Выполнение сборки 'ucd_regex' завершено!

clean:
	$(RM) $(UCMD_EXAMPLE)/*.v
	$(RM) $(UCMD_EXAMPLE)/_*.ucmd
	$(RM) $(UCMD_EXAMPLE)/*mem
	$(RM) $(UCMD_EXAMPLE)/*.svg
	$(RM) $(UCMD_EXAMPLE)/*.dot
	$(RM) $(UCMD_UART)/*.v
	$(RM) $(UCMD_UART)/_*.ucmd
	$(RM) $(UCMD_UART)/*mem
	$(RM) $(UCMD_UART)/*.svg
	$(RM) $(UCMD_UART)/*.dot
	$(RM) $(UCMD_REGEX)/*.v
	$(RM) $(UCMD_REGEX)/_*.ucmd
	$(RM) $(UCMD_REGEX)/*mem
	$(RM) $(UCMD_REGEX)/*.svg
	$(RM) $(UCMD_REGEX)/*.dot		
	@echo Cleanup complete!
