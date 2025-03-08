module uart_rx 
#(parameter data_width=8) (
  input clk,
  input rst,
  input clk_en,
  input rx,
  output [data_width-1:0] data_out,
  output data_valid
);

// Состояния автомата
parameter RX_IDLE  = 3'b000,
          RX_START = 3'b001,
          RX_DATA  = 3'b010,
          RX_STOP  = 3'b011,
          RX_ERROR = 3'b100,
          RX_VALID = 3'b101;
reg [2:0] rx_state;
reg [3:0] rx_fcnt; // Счетчик окна приема
reg [$clog2(data_width)-1:0] rx_bit_counter; //Счетчик бит данных
reg rx_en; //Сигнал разрешения приема бита данных в середине окна приема
reg [data_width-1:0] rx_data;

// выходные сигналы
assign data_out = rx_data;
assign data_valid = (rx_state==RX_VALID);

 // Генерация сигнала приема с настройкой на стартовый бит
always @(posedge clk) begin
  if (rst) begin
    rx_fcnt <= 0;
    rx_en <= 0;
  end else begin
    rx_en <= 1'b0;
    if (rx_state==RX_IDLE)
      rx_fcnt <= 0;
    else if (clk_en) begin
      rx_fcnt <= rx_fcnt + 1;
      if (rx_fcnt == 7) begin  //Окно приема == 7+1 бит
          rx_en <= 1'b1;
      end 
    end
  end
end

//Счетчик бит данных
always @(posedge clk) begin
  if (rst)
    rx_bit_counter <= 0;
  else if (rx_en)
    if (rx_state==RX_DATA) //приём данных
      rx_bit_counter <= rx_bit_counter + 1;
    else 
      rx_bit_counter <= 0;
end

//Регистр данных
always @(posedge clk) begin
  if (rst) begin
    rx_data <= 8'b0;
  end 
  else begin
    if (rx_en && rx_state == RX_DATA) //прием бита данных
        rx_data <= {rx, rx_data[7:1]};
  end
end

//Управляющий автомат
always @(posedge clk) begin
  if (rst) begin
    rx_state <= RX_IDLE;
  end 
  else begin
    case (rx_state)
      RX_IDLE:  if (rx==1'b0) rx_state <= RX_START;
      RX_START: if (rx_en) begin if (rx==1'b0) rx_state <= RX_DATA; else rx_state <= RX_ERROR; end
      RX_DATA:  if (rx_en && rx_bit_counter==7) rx_state <= RX_STOP;
      RX_STOP:  if (rx_en) begin if (rx==1'b1) rx_state <= RX_VALID; else rx_state <= RX_ERROR; end
      RX_ERROR: if (rx_en) rx_state <= RX_IDLE;
      RX_VALID: rx_state <= RX_IDLE;
      default: rx_state <= RX_IDLE;  
    endcase
  end
end

endmodule
