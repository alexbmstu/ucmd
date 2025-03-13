module uart_tx 
#(parameter data_width=8) (
  input clk,
  input rst,
  input clk_en,
  output reg tx,
  input [data_width-1:0] data_in,
  input data_valid,
  output data_ready
);

// Состояния автомата
parameter TX_IDLE  = 3'b000,
          TX_START = 3'b001,
          TX_DATA  = 3'b010,
          TX_STOP  = 3'b011,
          TX_READY = 3'b100;

reg [2:0] tx_state;
reg [$clog2(data_width)-1:0] tx_bit_counter; //Счетчик бит данных
wire [data_width-1:0] tx_data;
reg wr_data_ready;

// выходные сигналы
assign data_ready = (tx_state==TX_READY);
assign tx_data = data_in;
//Счетчик бит данных
always @(posedge clk) begin
  if (rst)
    tx_bit_counter <= 0;
  else if (clk_en)
    if (tx_state==TX_DATA) //приём данных
      tx_bit_counter <= tx_bit_counter + 1;
    else 
      tx_bit_counter <= 0;
end

//Регистр данных
always @(posedge clk) begin
  if (rst) begin
    tx <= 1'b1;
  end 
  else begin
    if (clk_en) begin
      if (tx_state == TX_START) //передача бита данных
        tx <= 1'b0;
      else if (tx_state == TX_DATA) //передача бита данных
        tx <= tx_data[tx_bit_counter];
      else
        tx <= 1'b1;
    end
  end
end

//Управляющий автомат
always @(posedge clk) begin
  if (rst) begin
    tx_state <= TX_IDLE;
  end 
  else begin
    case (tx_state)
      TX_IDLE:  if (data_valid) tx_state <= TX_START;
      TX_START: if (clk_en) tx_state <= TX_DATA;
      TX_DATA:  if (clk_en && tx_bit_counter==7) tx_state <= TX_STOP;
      TX_STOP:  if (clk_en) tx_state <= TX_READY;
      TX_READY: tx_state <= TX_IDLE;
      default: tx_state <= TX_IDLE;  
    endcase
  end
end

endmodule
