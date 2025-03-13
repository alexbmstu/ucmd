// fifo на lutram

module fifo_lutram #(parameter depth=8, data_width=8, read="reg") (
  input clk, rst,
  input w_en, r_en,
  input [data_width-1:0] data_in,
  output reg [data_width-1:0] data_out,
  output full, empty
);
  
  reg [$clog2(depth)-1:0] w_ptr, r_ptr;
  reg [data_width-1:0] fifo[0:depth-1];
  
  // Инициализация для моделирования
  integer i;
  initial begin
    for (i=0;i<depth;i=i+1)
      fifo[i] = 0;
  end
  
  // Запись данных в FIFO
  always@(posedge clk) begin
    if (rst)
      w_ptr <= 0;
    else if(w_en & !full)begin
      fifo[w_ptr] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end
  
  // Чтение данных из FIFO в выходной регистр
  always@(posedge clk) begin
    if (rst)
      r_ptr <= 0;
    else if(r_en & !empty) begin
      r_ptr <= r_ptr + 1;
    end
  end

  //Регистровый или комбинационный выходной регистр
  generate 
    if (read=="reg") begin
      // Чтение данных из FIFO в выходной регистр
      always@(posedge clk) begin
        if (rst)
          data_out <= 0;
        else if(r_en & !empty) begin
          data_out <= fifo[r_ptr];
        end
      end
    end
    else always@(*) data_out <= fifo[r_ptr];
  endgenerate
  
  assign full = ((w_ptr+1'b1) == r_ptr);
  assign empty = (w_ptr == r_ptr);

endmodule