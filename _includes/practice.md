<style>

/* By default, make all images center-aligned, and 60% of the width
of the screen in size */
img
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:90%;
}

/* Create a CSS class to style images to 90% */
.fullPic
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:100%;
}

/* Create a CSS class to style images to 60% */
.normalPic
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:60%;
}

/* Create a CSS class to style images to 40% */
.thinPic
{
    display:block;
    float:none;
    margin-left:auto;
    margin-right:auto;
    width:40%;
}

/* Create a CSS class to style images to 20% */
.smallPic
{
    display:inline-block;
    float:left;
    margin-left:none;
    margin-right:none;
    width:150px;
}

/* Create a CSS class to style images to left-align, or "float left" */
.leftAlign
{
    display:inline-block;
    float:left;
    /* provide a 15 pixel gap between the image and the text to its right */
    margin-right:15px;
}

/* Create a CSS class to style images to right-align, or "float right" */
.rightAlign
{
    display:inline-block;
    float:right;
    /* provide a 15 pixel gap between the image and the text to its left */
    margin-left:15px;
}
.image-caption {
  text-align: center;
  font-size: 1.0rem;
}

</style>

## 2. Порядок выполнения работы

### 2.1. Исследование работы асинхронного приемопередатчика UART

В первой части лабораторной работы рассмотрим пример использования микропрограммного автомата для тестирования универсального асинхронного приемопередатчика UART.
Для этого реализуем следующее устройство (смотри рисунок 3).

<img src="assets/uart_hello_world.png" alt="Функциональная схема устройства" style="width:600px;"/>

{:.image-caption}
**Рисунок 3 — Функциональная схема устройства**

Устройств получает от пользователя 8-битные слова по протоколу UART, анализирует их и выдает ответ в соответствии со следующей логикой:

- Если пользователь посылает символ `'0'` (ноль), то в ответ устройство посылает последовательность ASCII символов "Hello World!\n".  
- Если пользователь посылает любой другой символ, устройство без изменений посылает (режим "эхо").
  
Далее рассмотрим основы работы универсального асинхронного приемо-передатчика и затем соберем тестовый проект. 

#### 2.1.1. Описание протокола работы универсального асинхронного приемопередатчика UART

Протокол **UART** (Universal Asynchronous Receiver/Transmitter) — это один из самых распространенных протоколов для последовательной передачи данных между устройствами. Он используется для обмена данными между микроконтроллерами, компьютерами, датчиками и другими устройствами. UART является асинхронным протоколом, то есть для передачи данных не требуется общий тактовый сигнал. Протокол обмена данными позволяет передавать информацию одновременно в обе стороны (полный дуплекс). Для этого используются две сигнальные линии (приема и передачи). Как и в других последовательных протоколах , для UART принято маркировать не линии, а выходы устройств. Выход передатчика TX (transmit) одного устройства соединен проводником со входом приемника RX (receive) другого устройства. Обратный сигнал имеет аналогичную маркировку, направленную в противоположную сторону. Не следует забывать, что устройства на обоих концах линий должны быть надежно заземлены.

Скорость передачи UART задается в бодах (бит в секунду), причем в большинстве случаев используются стандартные скорости: 2400, 4800, 9600, 19200, 38400, 57600, 115200. Каждый байт данных передается в виде последовательности битов, обрамленной стартовым и стоповым битами. После последнего бита информационного слова может быть передан бит четности (опционально).    

Для успешной передачи данных оба устройства должны быть настроены с одинаковыми параметрами:
- **Скорость передачи (Baud Rate)**: Например, 9600, 115200 бод.
- **Количество бит данных**: Обычно 8 бит.
- **Бит четности**: Четность, нечетность или отсутствие.
- **Количество стоповых битов**: Обычно 1 или 2.

Наиболее распространена конфигурация 8-n-1 (8 бит в информационном слове, отсутствие контроля, один стоповый бит). Например, передача байта `0x55` (двоичное `01010101`) с 8 битами данных, без бита четности и 1 стоповым битом показана в таблице 1.

**Таблица 1. Пример передачи сообщения (байта `0x55`)**

| Стартовый бит | Бит 0 (LSB) | Бит 1 | Бит 2 | Бит 3 | Бит 4 | Бит 5 | Бит 6 | Бит 7 (MSB) | Стоповый бит |
|---------------|-------------|-------|-------|-------|-------|-------|-------|-------------|--------------|
| 0             | 1           | 0     | 1     | 0     | 1     | 0     | 1     | 0           | 1            |


#### 2.1.2. Структура проекта приемопередатчика UART

Проект состоит из следующих модулей:

1. **`uart_top`** — верхний уровень проекта, который объединяет все модули и обеспечивает взаимодействие с внешними устройствами.
2. **`uart`** — модуль верхнего уровня UART, который управляет передачей и приемом данных и содержит делители частоты для приемника и передатчика.
3. **`uart_tx`** — модуль передатчика UART, отвечающий за отправку данных.
4. **`uart_rx`** — модуль приемника UART, отвечающий за прием данных.
5. **`fifo_tx` и `fifo_rx`** — модули FIFO (очереди), используемые для буферизации данных при передаче и приеме.
6. **`uart_hello_world`** — модуль микропрограммного автомата, который реализует логику ответа на запросы по UART (например, отправка строки "Hello World!").

Устройство работает следующим образом. Данные поступают через линию `rx` в модуль `uart_rx` (файл `uart_rx.v`). После приема всех 8-ми бит сообщения и проверки на наличие стопового бита (значение логической единицы), принятые данные передаются в FIFO приемника `fifo_rx` (файл `fifo.v`). Данные из FIFO передаются в микропрограммный автомат (`uart_hello_world.v`). 

Микропрограммный автомат на основе очередного полученного байта определяет, совпадает ли он со значением "0". Если да, то автомат отправляет в очередь `fifo_tx` (файл `fifo.v`) ответ: строку "Hello World!\n". Если полученный байт не совпадает с "0", микропрограммный автомат выдает управляющий сигнал `echo`, который отправляет принятый символ обратно через очередь `fifo_tx`. 

Данные для передачи передаются из микропрограммного автомата или из очереди приемника в FIFO передатчика `fifo_tx`, после прохождения которой поступают в передатчик `uart_tx.v` (файл `uart_tx.v`). Далее модуль `uart_tx.v` отправляет данные через линию `tx` пользователю.



#### 2.1.3. Модуль верхнего уровня проекта (uart_top.v)

Этот модуль является верхним уровнем проекта. Основные функции модуля `uart_top.v`:
- Формирование сигналов тактирования приемопередатчика UART и задание скорости передачи.
- Формирование эхо-ответа по сигналу `echo`. 
- Вывод сигналов `rx` (прием) и `tx` (передача).

```verilog
// Модуль верхнего уровня проекта uart_top.v
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

```

#### 2.1.4. Модуль верхнего уровня UART (uart.v)

Этот модуль является верхним уровнем блока UART. Основные функции модуля:
- Деление частоты для синхронизации передатчика и приемника.
- Управление FIFO для передачи и приема данных.
- Обработка сигналов `wvalid`, `wready`, `rvalid`, `rready` для управления потоком данных между очередями и микропрограммным автоматом. 
- Управление передатчиком (`uart_tx.v`) и приемником (`uart_rx.v`).


```verilog
//Модуль верхнего уровня uart.v
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
```

#### 2.1.5. Автомат приемника UART (uart_rx.v)

Этот модуль реализует приемник UART. Информационная посылка поступает последовательно на вход `rx`. При поступлении стартового бита происходит выравнивание середины окна приема с помощью счетчика `rx_fcnt`. Далее момент приема бит служит для разрешения приема последующих битов данных и стопового бита.
Управление состоянием приемника выполняется с помощью конечного автомата, для которого заданы состояния: `IDLE`, `START`, `DATA`, `STOP`, `ERROR`, `VALID`.
Если формат пакета верный, то формируется сигнал `data_valid` для подтверждения успешного приема данных.

```verilog
//Модуль uart_rx.v
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
```

#### 2.1.6. Автомат передатчика UART (uart_tx.v)

Этот модуль реализует передатчик логику передачи слова UART через линию `tx`. Передача начинается в том случае, если в очереди передатчика нахзодится информация. 
При этом модуль формирует стартовый бит, далее управляет передачей восьми битов данных и стопового бита.
Управление состоянием передатчика также выполняется с помощью автомата (состояния `IDLE`, `START`, `DATA`, `STOP`, `READY`).
Контроль состояния очереди и переход к новому значению выполняется с помощью сигналов `data_valid` и `data_ready`. 

```verilog
// Модуль uart_tx.v
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

```

#### 2.1.7. FIFO очередь (fifo.v)

Этот модуль реализует FIFO (очередь) для буферизации данных при приеме и передаче. Состояние очереди выводится на линии `full` и `empty`. 

```verilog
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
```

#### 2.1.8. Микропрограммный автомат "Hello world" (uart_hello_world.v)

Этот модуль анализирует полученный символ и отвечает на него либо сигналом `echo=1` (для передачи входного байта в передатчик), либо последовательностью символов "Hello World\n". Для упраления входной и выходной очередями используются сигналы управления `wvalid` (готовность символа для очереди передатчика) и `rready` (готовность принять байт из очереди приемника). Автомат также анализирует осведомительные сигналы  `wready` (очередь передатчика готова к приему) и `rvalid` (очередь приемника готова к передаче). Запуск микропрограммного автомата выполняется при поступлении очередного символа в очередь приемника (сигнал `cmd0` принимает значение `rvalid`).


```js
//Описание управляющих сигналов автомата
@CONTROL
	wvalid;
	rready;
	putchar<7:0>;
	echo;	//Состояние сигналов по умолчанию: 1'b0
//Описание осведомительных сигналов автомата
@FEEDBACK
	wready;
	getchar<7:0>;е
//Сигналы кода команды
@CMD
	cmd0;
//Сигнал разрешения запуска микропрограммы
@RUN
	rvalid;
//Начальное состояние
IDLE0:
//Описание микропрограмм
//0x00 Микропрограмма 0 //Hello World
@IF (cmd0=0) => hello;
//Переход по умолчанию
@DEFAULT => IDLE0;
/////////////////////////////
//	   Микропрограмма 0    //
/////////////////////////////
//30h - '0'
hello: 			
  @IF(getchar<7:0>=s"0" & wready=1) => H;	  
@DEFAULT => echo;
//H
	H:			
    rready=1; wvalid=1; putchar<7:0>=s"H";		  
    @DEFAULT => H_w;
	H_w:
    @IF(wready=1) => e; 	  
    @DEFAULT => H_w;
//e
	e:			
    wvalid=1; putchar<7:0>=s"e";
    @DEFAULT => e_w;
	e_w:
    @IF(wready=1) => l0;
    @DEFAULT => e_w;
//l
	l0:
    wvalid=1; putchar<7:0>=s"l";
    @DEFAULT => l0_w;
	l0_w:												
    @IF(wready=1) => l1;
    @DEFAULT => l0_w;
//l
	l1:
    wvalid=1; putchar<7:0>=s"l";
    @DEFAULT => l1_w;
	l1_w:
    @IF(wready=1) => o0; 
    @DEFAULT => l1_w;
//o
	o0:
    wvalid=1; putchar<7:0>=s"o";
    @DEFAULT => o0_w;
	o0_w:
    @IF(wready=1) => space;
    @DEFAULT => o0_w;
//_
	space:		
    wvalid=1; putchar<7:0>=s" ";
    @DEFAULT => space_w;
	space_w:
    @IF(wready=1) => W;
    @DEFAULT => space_w;
//W
	W:
    wvalid=1; putchar<7:0>=s"W";
    @DEFAULT => W_w;
	W_w:
    @IF(wready=1) => o1;
    @DEFAULT => W_w;
//o
	o1:			
    wvalid=1; putchar<7:0>=s"o";								
    @DEFAULT => o1_w;
	o1_w:
    @IF(wready=1) => r;
    @DEFAULT => o1_w;
//r
	r:
    wvalid=1; putchar<7:0>=s"r";
    @DEFAULT => r_w;
	r_w:
    @IF(wready=1) => l2;
    @DEFAULT => r_w;
//l
	l2:
    wvalid=1; putchar<7:0>=s"l";
    @DEFAULT => l2_w;
	l2_w:
    @IF(wready=1) => d;
    @DEFAULT => l2_w;
//d
	d:
    wvalid=1; putchar<7:0>=s"d";
    @DEFAULT => d_w;
	d_w:
    @IF(wready=1) => yeah;
    @DEFAULT => d_w;
//!
	yeah:
    wvalid=1; putchar<7:0>=s"!";
    @DEFAULT => yeah_w;
	yeah_w:
    @IF(wready=1) => end;
    @DEFAULT => yeah_w;
//#0d
	end:
    wvalid=1; putchar<7:0>=8h"0d"; 
    @DEFAULT => IDLE0;
//echo send
	echo:		
    echo=1;
    @DEFAULT => IDLE0;

```

Диаграмма состояний микропрограммного автомата показана на рисунке 4.

<img src="data/ucmd/ucmd_dest/uart_hello_world.svg" alt="Диаграмма переходов состояний микропрограммного автомата Hello world!" style="width:400px;"/>

{:.image-caption}
**Рисунок 4 — Диаграмма переходов состояний микропрограммного автомата Hello world!**


#### 2.1.9. Сборка и тестирование приемопередатчика UART

* Выполните следующие команды:

```bash
# Перейти в домашнюю директорию
cd ~
mkdir lab2
cd lab2
mkdir part1
```
* В директории `~/lab2/part1` cоздайте файлы, указанные в пунктах  `2.1.2-2.1.8`.
* Выполните генерацию микропрограммного автомата из директории `~/lab2`, выполнив команду:

```bash
git clone https://gitlab.bmstu.ru/iu6-hardware-section/verilog-labs/ucmd.git
cd ~/lab2/ucmd/data/ucmd/utils
make uart
```
Структура папок с исходным описанием проектов: 
- `ucmd/data` - директория с исходными описаниями
  - `rtl` - директория с файлами описаний на языке Verilog
    - `ucmd_hello_world` - директория с файлами описаний на языке Verilog части 1
    - `ucmd_regex` -  директория с файлами описаний на языке Verilog части 2
  - `ucmd` - директория с описаниями микропрограмм
    - `utils` -  директория с утилитой генерации микропрограммных автоматов `ucmd`
    - `ucmd_src` - директория с файлами миркопрограмм
    - `ucmd_dest` - директория с результатами генерации

В итоге в `~/lab2/ucmd/data/ucmd/ucmd_dest` будут созданы файлы `uart_hello_world.v`, `uart_hello_world.adrmem`  и `uart_hello_world.mcmem`. 
Скопируйте их директорию `~/lab2/part1`.

Дополнительно в директории `~/lab2/part1` создайте файл ограничений uart_top.ucf

```tcl
##
## 5   on X5 / 66MHz
NET "clk" LOC = U23;
NET "clk" TNM_NET = "userclk";
# 66 Mhz
TIMESPEC ts0 = PERIOD "userclk" 15.0015 ns HIGH 50 %;
## 2   on SW10 pushbutton (active-high)
NET "rst" LOC = H10;
NET "rst" TIG;
## 2   on LED DS20 north
#NET "locked" LOC = AH27;
NET "rx"                      LOC = "J24";    ## 24  on U34
NET "tx"                      LOC = "J25";    ## 25  on U34
```

* Создайте в директории `~/lab2/part1` файл `part1.tcl` для автоматического создания проекта:

```tcl
# Файл part1.tcl
# Директория, где будут создан проект
cd part1
# Модуль верхнего уровня:
set top_name uart_top
# входные исходные файлы:
set hdl_files [ list fifo.v uart.v uart_hello_world.v uart_rx.v uart_top.v uart_tx.v uart.top.ucf]
# Настройки проекта
project new $top_name.ise
project set family Virtex6
project set device xc6vlx240t
project set package ff1156
project set speed -1
# Добавление исходных описаний в проект
foreach filename $hdl_files {
    xfile add $filename
    puts "Добавление файла $filename в проект."
}

```

* Запустите созданный скрипт tcl скрипт во вкладке TCL Console:

```tcl
cd ~/lab2/part1
source part1.tcl
```

В итоге будет сформирован проект устройства.

* Запустите сборку проекта в окне процессов в пунке меню `Generate Programming File` или командой tcl:

```tcl
process run "Generate Programming File" -force rerun_all
```

* Выполните тестирование устроства на плате Xilinx ML605. Для приема и передачи информации по `UART` подключите usb-кабель к разъему платы с маркировкой `UART`. Далее запустите на компьютере терминал и выполните команду: 
```bash
screen /dev/ttyUSB0
```

После этого вы сможете вводить символы с клавиатуры. При передаче символа `0`

> **В отчет:**  Занесите в отчет результаты тестирования устройства. 

### 2.2. Разработка микропрограммного автомата для распознавания предложений по регулярным выражениям

Во второй части необходимо по индивидуальному варианту разработать микропрограммный автомат, который принимает на вход последовательность ASCII символов, и выполняет проверку их последовательности на соотевтствие регулярному выражению. Символы, как и в первой части задания, вводятся пользователем с клавиатуры и передаются по интерфейсу `UART`. Для реализации устройства используются модули первой части лабораторной работы. 

Для распознавания классов символов необходимо добавить в проект модуль декодера классов символов `ascii_type_detector`. 

#### 2.2.1. Декодер классов символов

Код модуля показан ниже. Она представляет собой компбинационную схему, на вход которой подается символ ascii, а на выходе вормируются сигналы соответствия: 
- **small_letter** -  Строчная буква (a-z).
- **capital_letter** -  Заглавная буква (A-Z).
- **number** -  Цифра (0-9).
- **hex_digit** -  Шестнадцатеричная цифра (0-9, A-F, a-f).
- **punctuation_basic** -  Основные знаки препинания (., ,, :, ;, !, ?, ', ").
- **punctuation_finance** -  Финансовые символы (#, $, %, &, @).
- **parentheses** -  Скобки ((, ), [, ]).
- **curly_braces** -  Фигурные скобки ({, }) - добавлено.
- **math_symbol** -  Математические символы (+, -, *, /, \, =, <, >).
- **whitespace** -  Пробельные символы (пробел, табуляция, перевод строки, возврат каретки).
- **vowel** - Гласные буквы [aeiouAEIOU].
- **start_stop** - Начало и конец строки (\0).
- **other** - Другие символы.


```Verilog
module ascii_type_detector (
  input wire [7:0] ascii_char,
  output reg small_letter, // Строчная буква (a-z)
  output reg capital_letter, // Заглавная буква (A-Z)
  output reg number, // Цифра (0-9)
  output reg hex_digit, // Шестнадцатеричная цифра (0-9, A-F, a-f)
  output reg punctuation_basic, // Основные знаки препинания (., ,, :, ;, !, ?, ', ")
  output reg punctuation_finance, // Финансовые символы (#, $, %, &, @)
  output reg parentheses, // Скобки ((, ), [, ])
  output reg curly_braces, // Фигурные скобки ({, }) - добавлено
  output reg math_symbol, // Математические символы (+, -, *, /, \, =, <, >)
  output reg whitespace, // Пробельные символы (пробел, табуляция, перевод строки, возврат каретки)
  output reg vowel, //Гласные буквы [aeiouAEIOU]
  output reg start_stop, //Начало и конец строки (\0)
  output reg other // Другие символы
);

  always @(*) begin
    small_letter = 1'b0;
    capital_letter = 1'b0;
    number = 1'b0;
    hex_digit = 1'b0;
    punctuation_basic = 1'b0;
    punctuation_finance = 1'b0;
    parentheses = 1'b0;
    curly_braces = 1'b0; 
    math_symbol = 1'b0;
    whitespace = 1'b0;
    vowel = 1'b0;
    start_stop = 1'b0;
    other = 1'b0;
    if (ascii_char >= 8'h61 && ascii_char <= 8'h7a) small_letter = 1'b1;
    if (ascii_char >= 8'h41 && ascii_char <= 8'h5a) capital_letter = 1'b1;
    if (ascii_char >= 8'h30 && ascii_char <= 8'h39) number = 1'b1;
    if (ascii_char >= 8'h41 && ascii_char <= 8'h46) hex_digit = 1'b1;
    if (ascii_char >= 8'h61 && ascii_char <= 8'h66) hex_digit = 1'b1;
    if (ascii_char == 8'h2E || ascii_char == 8'h2C || ascii_char == 8'h3A || ascii_char == 8'h3B || ascii_char == 8'h21 || ascii_char == 8'h3F || ascii_char == 8'h27 || ascii_char == 8'h22) punctuation_basic = 1'b1;
    if (ascii_char == 8'h23 || ascii_char == 8'h24 || ascii_char == 8'h25 || ascii_char == 8'h26 || ascii_char == 8'h40) punctuation_finance = 1'b1;
    if (ascii_char == 8'h28 || ascii_char == 8'h29 || ascii_char == 8'h5B || ascii_char == 8'h5D) parentheses = 1'b1;
    if (ascii_char == 8'h7B || ascii_char == 8'h7D) curly_braces = 1'b1; 
    if (ascii_char == 8'h2B || ascii_char == 8'h2D || ascii_char == 8'h2A || ascii_char == 8'h2F || ascii_char == 8'h5C || ascii_char == 8'h3D || ascii_char == 8'h3C || ascii_char == 8'h3E) math_symbol = 1'b1;
    if (ascii_char == 8'h20 || ascii_char == 8'h09 || ascii_char == 8'h0A || ascii_char == 8'h0D) whitespace = 1'b1;
    if (ascii_char == 8'h61 || ascii_char == 8'h65 || ascii_char == 8'h69 || ascii_char == 8'h6f || ascii_char == 8'h75 || ascii_char == 8'h41 || ascii_char == 8'h45 || ascii_char == 8'h49 || ascii_char == 8'h4f || ascii_char == 8'h55) vowel = 1'b1;
    if (!(small_letter | capital_letter | number | hex_digit | punctuation_basic | punctuation_finance | parentheses | curly_braces | math_symbol | whitespace)) other = 1'b1;
    if (ascii_char == 8'h0 || ascii_char == 8'h0A) start_stop = 1'b1;
  end
endmodule
```

#### 2.1.2. Модуль верхнего уровня

Необходимо внести изменения в модуль верхнего уровня: добавить декодера классов символов и удалить эхо-режим работы устройства. 

```Verilog
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
wire small_letter; // Строчная буква (a-z)
wire capital_letter; // Заглавная буква (A-Z)
wire number; // Цифра (0-9)
wire hex_digit; // Шестнадцатеричная цифра (0-9, A-F, a-f)
wire punctuation_basic; // Основные знаки препинания (., ,, :, ;, !, ?, ', ")
wire punctuation_finance; // Финансовые символы (#, $, %, &, @)
wire parentheses; // Скобки ((, ), [, ])
wire curly_braces; // Фигурные скобки ({, }) - добавлено
wire math_symbol; // Математические символы (+, -, *, /, \, =, <, >)
wire whitespace; // Пробельные символы (пробел, табуляция, перевод строки, возврат каретки)
wire vowel; //Гласные буквы [aeiouAEIOU]
wire start_stop; //Начало и конец строки (\0)
wire other; // Другие символы

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
top_ucmd_fsm_example #(.fpga_type("virtex")) ucmd_inst (
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
```

#### 2.1.3. Регулярные выражения

 **Регулярные выражения (regular expressions, regex)** используются для работы с последовательностями символов, позволяя находить, извлекать или заменять фрагменты текста, которые соответствуют определённым правилам.

Основные правила записи регулярных выражений:
1. **Шаблон (pattern)**: это строка, которая описывает правило для поиска. Например, шаблон `\d{3}` ищет последовательность из трёх цифр.
2. **Литералы** (например, `a`, `1`, `@`) в записи регулярного выражения позволяют выразить наличие соотетствующих им символов в обрабатываемом тексте (представляют свое непосредственное значение). 
3. **Метасимволы**: это текстовые символы из ограниченного множества знаков (например, `.`, `*`, `+`, `?`, `\d`), кторые имеют специальное значение и используются для создания сложных шаблонов. Если необходимо представить символ, совпадающий с метасимволом, то он экранируется знаком `\` (например, `\+`). Перечислим некоторые часто употребимые метасимволы:  

| Символ | Описание                                      |
|--------|-----------------------------------------------|
|        | **Специальные символы**                       |
|--------|-----------------------------------------------|
| `.`    | Любой символ, кроме новой строки.             |
| `\d`   | Цифра (`[0-9]`).                              |
| `\D`   | Не цифра (`[^0-9]`).                          |
| `\w`   | Буква, цифра или нижнее подчеркивание (`[a-zA-Z0-9_]`). |
| `\W`   | Не буква, не цифра и не нижнее подчеркивание.  |
| `\s`   | Пробельный символ (пробел, табуляция, новая строка). |
| `\S`   | Не пробельный символ.                         |
| `\b`   | Граница слова.                                |
| `\B`   | Не граница слова.                             |
| `\B`   | Не граница слова.                             |
|--------|-----------------------------------------------|
|        | **Квантификаторы**                            |
|--------|-----------------------------------------------|
| `*`     | 0 или более повторений.                       |
| `+`     | 1 или более повторений.                       |
| `?`     | 0 или 1 повторение.                           |
| `{n}`   | Ровно `n` повторений.                         |
| `{n,}`  | `n` или более повторений.                     |
| `{n,m}` | От `n` до `m` повторений.                     |
|--------|-----------------------------------------------|
|        | **Группы и альтернативы**                     |
|--------|-----------------------------------------------|
| `()`   | Группа.                                       |
| `|`    | Альтернатива (или).                           |
|--------|-----------------------------------------------|
|        | **Классы символов**                           |
|--------|-----------------------------------------------|
| `[abc]`   | Любой из символов `a`, `b`, `c`.              |
| `[^abc]`  | Любой символ, кроме `a`, `b`, `c`.            |
| `[a-z]`   | Диапазон символов от `a` до `z`.              |
|--------|-----------------------------------------------|
|        | **Начало и конец строки**                     |
|--------|-----------------------------------------------|
| `^`    | Начало строки.                                |
| `$`    | Конец строки.                                 |


Приведем простые примеры регулярных выражений: 

- `abc` — строка `abc`.
- `a.c` — строка, где между `a` и `c` любой символ (например, `abc`, `aXc`).
- `a+` — одна или более букв `a`.
- `a{2,4}` — от 2 до 4 букв `a`.
- `(abc)+` — одна или более последовательностей `abc`.
- `[a-zA-Z]` — любая буква латинского алфавита.
- `[0-9]{3}` — три цифры.
- `^abc` — строка, начинающаяся с `abc`.
- `abc$` — строка, заканчивающаяся на `abc`.
- `\*` — соответствует символу `*`.
- `[\w\.-]+@[\w\.-]+\.\w+` - поиск email-адресов в тексте.


#### 2.1.3. Индивидуальные задания

На основе шаблона `data/ucmd/ucmd_src/uart_regex.ucmd` необходимо  разработать микропрограмму, распознающую входную последовательность символов в соотетствии с регулярный выражением. Если последовательность распознана, микропрограммный автомат посылает по интерфейсу UART символ `1`, в противном случае посялается символ `0`.

Генерация микропограммного автомата выполняется по команде:
```bash
cd ~/lab2/data/ucmd/utils
make regex
```



**Индивидуальные задания**

1. **Регулярное выражение**: `([a-zA-Z]{2,}[0-9]{1,}){2,}`  (Последовательность букв и цифр, повторенная два или более раза).
  Примеры строк:
   - `abc123xyz456`
   - `Hello42World99`
   - `test01example02`


2. **Регулярное выражение**: `([A-Z][a-z]+[0-9]{2}){3,}` (Заглавная буква, строчные буквы и две цифры, повторенные три или более раза).
  Примеры строк:
   - `Hello42World99Test01`
   - `User12Name34Code56`
   - `Alpha01Beta02Gamma03`

3. **Регулярное выражение**: `[a-fA-F0-9]{4,}([.,:;!?'"]{1}[a-zA-Z]+){2,}` (Шестнадцатеричное число, за которым следуют базовые знаки препинания и буквы, повторенные два или более раза).
  Примеры строк:
   - `1A3F,abc!xyz`
   - `BEEF:test?example`
   - `DEAD:code!data`

4. **Регулярное выражение**: `([#$%@&]{1}[0-9]+){3,}`  (Финансовые знаки препинания, за которыми следуют цифры, повторенные три или более раза).
  Примеры строк:
   - `#123$456%789`
   - `@100$200%300`
   - `#999&888@777`

5. **Регулярное выражение**: `([()\[\]]{1}[a-zA-Z]+){2,}` (Скобки, за которыми следуют буквы, повторенные два или более раза).
  Примеры строк:
   - `(abc)[xyz]`
   - `[test](example)`
   - `(hello)[world]`

6. **Регулярное выражение**: `[{}]{1}[0-9]+([+\-*/\\=<>]{1}[a-zA-Z]+){2,}` (Фигурные скобки, за которыми следуют цифры, а затем математические символы и буквы, повторенные два или более раза).
   Примеры строк:
   - `{123}+abc*xyz`
   - `{456}-test=example`
   - `{789}/hello<world`
  
7. **Регулярное выражение**: `(\s{1}[a-zA-Z]+){3,}` (Пробельные символы, за которыми следуют буквы, повторенные три или более раза).
   Примеры строк:
   - ` abc def ghi`
   - ` test example code`
   - ` hello world regex`   

8. **Регулярное выражение**: `([aeiouAEIOU]{1}[0-9]+){2,}`  (Гласные буквы, за которыми следуют цифры, повторенные два или более раза).

   Примеры строк:
   - `a1e2i3`
   - `E4U5O6`
   - `i7A8e9`

9.  **Регулярное выражение**: `(\0{1}[a-zA-Z]+){2,}`  (Нулевые символы, за которыми следуют буквы, повторенные два или более раза).
   Примеры строк:
   - `\0abc\0xyz`
   - `\0test\0example`
   - `\0hello\0world`

10. **Регулярное выражение**: `([a-zA-Z]+[.,:;!?'"]{1}){3,}`  (Буквы, за которыми следуют базовые знаки препинания, повторенные три или более раза).
   Примеры строк:
   - `abc,xyz!test:`
   - `hello,world!example?`
   - `code:test!data?`

11. **Регулярное выражение**: `([0-9]+[#$%@&]{1}){2,}`  (Цифры, за которыми следуют финансовые знаки препинания, повторенные два или более раза).
   Примеры строк:
   - `123#456$`
   - `789@100%`
   - `200&300#`


12. **Регулярное выражение**: `([a-zA-Z]+[()\[\]]{1}){3,}` (Буквы, за которыми следуют скобки, повторенные три или более раза).
   Примеры строк:
   - `abc(xyz)[test]`
   - `hello(world)[example]`
   - `code(test)[data]`

13. **Регулярное выражение**: `([0-9]+[{}]{1}){2,}`   (Цифры, за которыми следуют фигурные скобки, повторенные два или более раза).
   Примеры строк:
   - `123{}456{}`
   - `789{}100{}`
   - `200{}300{}`

14. **Регулярное выражение**: `([a-zA-Z]+[+\-*/\\=<>]{1}){3,}` (Буквы, за которыми следуют математические символы, повторенные три или более раза).
   Примеры строк:
   - `abc+xyz=test`
   - `hello-world*example`
   - `code/test=data`

15. **Регулярное выражение**: `([0-9]+\s{1}){2,}` (Цифры, за которыми следуют пробельные символы, повторенные два или более раза).
   Примеры строк:
   - `123 456 `
   - `789 100 `
   - `200 300 `

16. **Регулярное выражение**: `([a-zA-Z]+[aeiouAEIOU]{1}){3,}` (Буквы, за которыми следуют гласные буквы, повторенные три или более раза).
   Примеры строк:
   - `abcAxyzEtestI`
   - `helloOworldU`
   - `codeEexampleA`

17. **Регулярное выражение**: `([a-zA-Z]{2,}[0-9]{1,}[.,:;!?'"]{1}){2,}` (Буквы, цифры и базовые знаки препинания, повторенные два или более раза).
   Примеры строк:
   - `abc123,xyz456!`
   - `test01:example02?`
   - `hello42,world99!`

18. **Регулярное выражение**: `([A-Z][a-z]+[0-9]{2}[#$%@&]{1}){2,}`  (Заглавные буквы, строчные буквы, цифры и финансовые знаки препинания, повторенные два или более раза).
   Примеры строк:
   - `Hello42#World99$`
   - `User12@Code56%`
   - `Alpha01&Beta02#`

19. **Регулярное выражение**: `([a-fA-F0-9]{4,}[()\[\]]{1}[a-zA-Z]+){2,}`  (Шестнадцатеричные числа, скобки и буквы, повторенные два или более раза).
   Примеры строк:
   - `1A3F(abc)5B6D[xyz]`
   - `DEAD(test)BEEF[example]`
   - `FACE(hello)CODE[world]`


20. **Регулярное выражение**: `([{}]{1}[0-9]+[+\-*/\\=<>]{1}[a-zA-Z]+){2,}`  (Фигурные скобки, цифры, математические символы и буквы, повторенные два или более раза).
   Примеры строк:
   - `{123}+abc*xyz`
   - `{456}-test=example`
   - `{789}/hello<world`

21. **Регулярное выражение**: `(\s{1}[a-zA-Z]+[aeiouAEIOU]{1}){3,}`  (Пробельные символы, буквы и гласные буквы, повторенные три или более раза).
   Примеры строк:
   - ` abcA defE ghiI`
   - ` testO exampleU`
   - ` helloA worldE`

22. **Регулярное выражение**: `(\0{1}[a-zA-Z]+[0-9]+){2,}`  (Нулевые символы, буквы и цифры, повторенные два или более раза).
   Примеры строк:
   - `\0abc123\0xyz456`
   - `\0test789\0example100`
   - `\0hello200\0world300`

23. **Регулярное выражение**: `([a-zA-Z]+[.,:;!?'"]{1}[0-9]+){2,}`   (Буквы, базовые знаки препинания и цифры, повторенные два или более раза).
   Примеры строк:
   - `abc,123xyz!456`
   - `hello:789world?100`
   - `test!200example,300`

24. **Регулярное выражение**: `([0-9]+[#$%@&]{1}[a-zA-Z]+){2,}`    (Цифры, финансовые знаки препинания и буквы, повторенные два или более раза).
   Примеры строк:
   - `123#abc456$xyz`
   - `789@test100%example`
   - `200&hello300#world`

25. **Регулярное выражение**: `([a-zA-Z]+[()\[\]]{1}[0-9]+){2,}`   (Буквы, скобки и цифры, повторенные два или более раза).
   Примеры строк:
   - `abc(123)xyz[456]`
   - `hello(789)world[100]`
   - `test(200)example[300]`

26. **Регулярное выражение**: `([0-9]+[{}]{1}[a-zA-Z]+){2,}`  (Цифры, фигурные скобки и буквы, повторенные два или более раза).
   Примеры строк:
   - `123{}abc456{}xyz`
   - `789{}test100{}example`
   - `200{}hello300{}world`

27. **Регулярное выражение**: `([a-zA-Z]+[+\-*/\\=<>]{1}[0-9]+){2,}`  (Буквы, математические символы и цифры, повторенные два или более раза).
   Примеры строк:
   - `abc+123xyz=456`
   - `hello-789world*100`
   - `test/200example=300`

28. **Регулярное выражение**: `([0-9]+\s{1}[a-zA-Z]+){2,}`  (Цифры, пробельные символы и буквы, повторенные два или более раза).
   Примеры строк:
   - `123 abc456 xyz`
   - `789 test100 example`
   - `200 hello300 world`

29. **Регулярное выражение**: `([a-zA-Z]+[aeiouAEIOU]{1}[0-9]+){2,}`  (Буквы, гласные буквы и цифры, повторенные два или более раза).
   Примеры строк:
   - `abcA123xyzE456`
   - `helloO789worldU100`
   - `testE200exampleA300`

30. **Регулярное выражение**: `([a-zA-Z]{2,}[0-9]{1,}[.,:;!?'"]{1}[#$%@&]{1}){2,}` (Буквы, цифры, базовые знаки препинания и финансовые знаки препинания, повторенные два или более раза).
   Примеры строк:
   - `abc123,#xyz456!$`
   - `hello789:@world100%`
   - `test200!&example300#`
