//     uart_top.v
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

assign wdata = (echo)? rdata: wdata_ucmd;
assign wvalid = (echo)? rvalid: wvalid_ucmd;
assign rready = (echo)? wready: rready_ucmd;


// Instantiate the module
top_ucmd_fsm_uart_hello_world #(.fpga_type("virtex")) uart_hello_world (
    .rst(rst), 
    .clk(clk), 
    .debug(), 
    .rvalid(rvalid), 
    .cmd0(0), 
    .wready(wready), 
    .getchar(rdata), 
    .wvalid(wvalid_ucmd), 
    .rready(rready_ucmd), 
    .putchar(wdata_ucmd), 
	  .echo(echo),
    .ucmdRAM_data(0), 
    .ucmdRAM_adr(0), 
    .ucmdRAM_we(1'b0), 
    .ucmdARAM_data(0), 
    .ucmdARAM_adr(0), 
    .ucmdARAM_we(1'b0), 
    .busy()
    );

endmodule

