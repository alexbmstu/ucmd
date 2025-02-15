//Модуль верхнего уровня uart
module uart 
#(parameter frequency=66000000, parameter baudrate=115200, parameter data_width=8) (
  input  clk,
  input  rst,
  input  rx,
  output tx,
  //read data from rx fifo
  output[data_width-1:0] rdata,
  output rvalid,
  input rready,
  //write data to tx fifo
  input[data_width-1:0] wdata,
  output wready,
  input wvalid
);

localparam tx_fdiv_value = frequency/baudrate; //Счетное значение для синхронизации передатчика
localparam rx_fdiv_value = tx_fdiv_value/16; //Счетное значение для синхронизации приемника в 16 раз меньше

wire rx_fifo_w_en,rx_fifo_r_en;
wire tx_fifo_w_en,tx_fifo_r_en;
reg rx_en,tx_en;
wire [data_width-1:0] rx_fifo_data_in,rx_fifo_data_out;
wire [data_width-1:0] tx_fifo_data_in,tx_fifo_data_out;
wire rx_fifo_empty,rx_fifo_full;
wire tx_fifo_empty,tx_fifo_full;

reg [31:0] rx_fdiv; // Счетчик для деления частоты приемника
reg [31:0] tx_fdiv; // Счетчик для деления частоты передатчика

//Выходные сигналы
assign rvalid = ~rx_fifo_empty;
assign wready = ~tx_fifo_full;
assign rdata = rx_fifo_data_out;

//внутренние сигналы
assign rx_fifo_r_en = rready;
assign tx_fifo_w_en = wvalid;
assign tx_fifo_data_in = wdata;

// Разрешения тактирования передатчика
always @(posedge clk) begin
  if (rst) begin
      tx_fdiv <= 0;
      tx_en <= 0;
  end else begin
      tx_fdiv <= tx_fdiv + 1;
      if (tx_fdiv == tx_fdiv_value-1) begin 
          tx_fdiv <= 0;
          tx_en <= 1'b1;
      end else begin
          tx_en <= 1'b0;
      end
  end
end

// Разрешения тактирования приемника
always @(posedge clk) begin
  if (rst) begin
      rx_fdiv <= 0;
      rx_en <= 0;
  end else begin
      rx_fdiv <= rx_fdiv + 1;
      if (rx_fdiv == rx_fdiv_value-1) begin 
          rx_fdiv <= 0;
          rx_en <= 1'b1;
      end else begin
          rx_en <= 1'b0;
      end
  end
end

//rx
uart_rx #(.data_width(8)) rx_inst (
  .clk(clk), .rst(rst),.rx(rx),.clk_en(rx_en),
  .data_out(rx_fifo_data_in),
  .data_valid(rx_fifo_w_en)
);

//tx
uart_tx #(.data_width(8)) tx_inst (
  .clk(clk), .rst(rst),.tx(tx),.clk_en(tx_en),
  .data_in(tx_fifo_data_out),
  .data_valid(~tx_fifo_empty),
  .data_ready(tx_fifo_r_en)
);

//rx fifo
fifo_lutram #(.depth(8), .data_width(8), .read("noreg")) rx_fifo (
  .clk(clk), .rst(rst),
  .w_en(rx_fifo_w_en), .r_en(rx_fifo_r_en),
  .data_in(rx_fifo_data_in),
  .data_out(rx_fifo_data_out),
  .full(rx_fifo_full), .empty(rx_fifo_empty)
);

//tx_fifo
fifo_lutram #(.depth(8), .data_width(8), .read("noreg")) tx_fifo (
  .clk(clk), .rst(rst),
  .w_en(tx_fifo_w_en), .r_en(tx_fifo_r_en),
  .data_in(tx_fifo_data_in),
  .data_out(tx_fifo_data_out),
  .full(tx_fifo_full), .empty(tx_fifo_empty)
);

endmodule
