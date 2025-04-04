//  

module uart_top
#(parameter frequency=66000000, parameter baudrate=115200, parameter data_width=8) (
  input  clk,
  input  rst,
  input  rx,
  output tx
);

//read data from rx fifo
wire [data_width-1:0] rdata;
wire rvalid;
wire rready;
//write data to tx fifo
wire[data_width-1:0] wdata;
wire wready;
wire wvalid;
wire echo;
wire [data_width-1:0] wdata_ucmd;
wire wvalid_ucmd;
wire rready_ucmd;
//ascii detection
wire small_letter; //   (a-z)
wire capital_letter; //   (A-Z)
wire number; //  (0-9)
wire hex_digit; //   (0-9, A-F, a-f)
wire punctuation_basic; //    (., ,, :, ;, !, ?, ', ")
wire punctuation_finance; //   (#, $, %, &, @)
wire parentheses; //  ((, ), [, ])
wire curly_braces; //   ({, }) - 
wire math_symbol; //   (+, -, *, /, \, =, <, >)
wire whitespace; //   (, ,  ,  )
wire vowel; //  [aeiouAEIOU]
wire start_stop; //    (\0)
wire other; // 



uart #(.frequency(frequency), .baudrate(baudrate), .data_width(8)) uart_inst (
  .clk(clk),
  .rst(rst),
  .rx(rx),
  .tx(tx),
  //read data from rx fifo
  .rdata(rdata),
  .rvalid(rvalid),
  .rready(rready),
  //write data to tx fifo
  .wdata(wdata),
  .wready(wready),
  .wvalid(wvalid)
);

assign wdata = wdata_ucmd;
assign wvalid = wvalid_ucmd;
assign rready = rready_ucmd;


// Instantiate the ascii detection module
ascii_type_detector ascii_type_detector_inst (
    .ascii_char(rdata), 
    .small_letter(small_letter), 
    .capital_letter(capital_letter), 
    .number(number), 
    .hex_digit(hex_digit), 
    .punctuation_basic(punctuation_basic), 
    .punctuation_finance(punctuation_finance), 
    .parentheses(parentheses), 
    .curly_braces(curly_braces), 
    .math_symbol(math_symbol), 
    .whitespace(whitespace), 
    .vowel(vowel), 
    .start_stop(start_stop), 
    .other(other)
    );

// Instantiate the ucmd module
top_ucmd_fsm_regex #(.fpga_type("virtex")) ucmd_inst (
    .rst(rst), 
    .clk(clk), 
    .debug(), 
    .rvalid(rvalid), 
    .cmd0(0), 
    .wready(wready),
	 .start(rvalid),
	 .whitespace(whitespace),
	 .vowel(vowel),
	 .start_stop(start_stop),
	 .small_letter(small_letter),
	 .punctuation_finance(punctuation_finance),
	 .punctuation_basic(punctuation_basic),
	 .parentheses(parentheses),
	 .other(other),
	 .number(number),
	 .math_symbol(math_symbol),
	 .hex_digit(hex_digit),
	 .curly_braces(curly_braces),
	 .capital_letter(capital_letter),
    .wvalid(wvalid_ucmd), 
    .rready(rready_ucmd), 
    .putchar7(wdata_ucmd[7]), 
    .putchar6(wdata_ucmd[6]), 
    .putchar5(wdata_ucmd[5]), 
    .putchar4(wdata_ucmd[4]), 
    .putchar3(wdata_ucmd[3]), 
    .putchar2(wdata_ucmd[2]), 
    .putchar1(wdata_ucmd[1]), 
    .putchar0(wdata_ucmd[0]), 
    .ucmdRAM_data(0), 
    .ucmdRAM_adr(0), 
    .ucmdRAM_we(1'b0), 
    .ucmdARAM_data(0), 
    .ucmdARAM_adr(0), 
    .ucmdARAM_we(1'b0), 
    .busy()
    );

endmodule
