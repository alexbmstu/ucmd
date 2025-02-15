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
top_ucmd_fsm_example #(.fpga_type("virtex")) hello_world (
    .rst(rst), 
    .clk(clk), 
    .debug(), 
    .rvalid(rvalid), 
    .cmd0(0), 
    .wready(wready), 
    .getchar7(rdata[7]), 
    .getchar6(rdata[6]), 
    .getchar5(rdata[5]), 
    .getchar4(rdata[4]), 
    .getchar3(rdata[3]), 
    .getchar2(rdata[2]), 
    .getchar1(rdata[1]), 
    .getchar0(rdata[0]), 
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
