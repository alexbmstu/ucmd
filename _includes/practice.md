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

### 2.1. Исследование работы сумматора с передачей переноса по цепочке замкнутых ключей (CLA)

#### 2.1.1. Исследование результатов синтеза многоразряднго сумматора

В данном задании создадим простой многоразрядный сумматор на основе примитивного Verilog описания и исследуем результаты его синтеза в САПР Xilinx ISE.

* Выполните следующие команды:

```bash
# Перейти в домашнюю директорию
cd ~
mkdir lab1
cd lab1
mkdir part1
```

* В директории `~/lab1` создадим файл `adder.v`:

```Verilog
// Файл adder.v
module adder #(
  //CLA сумматор синтезируется для w>=6
  parameter w = 6 
)
(
  input [w-1:0]	a,
  input [w-1:0]	b,
  output [w:0]  sum
);
  assign sum = a + b;
endmodule
```

* Создайте в директории файл `part1.tcl` для автоматического создания проекта:

```tcl
# Файл part1.tcl
# Директория, где будут создан проект
cd part1
# Модуль верхнего уровеня:
set top_name adder
# входные исходные файлы:
set hdl_files [ list \
../adder.v]
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
cd ~/lab1
source part1.tcl
```

В итоге будет сформирован проект, показанный на рисунке 4.

<img src="assets/part1_img1.png" alt="Проект сумматора в САПР Xilinx ISE 14.7" style="width:800px;"/>

{:.image-caption}
**Рисунок 4 — Проект сумматора в САПР Xilinx ISE 14.7**



* В свойствах процесса `Synthesize - XST / Xilinx Specific Options` снимите флаг `iobuf` или запустите tcl команду:
* 
```tcl
project set "add i/o buffers" false
``` 
Это упростит итоговую схему, так как не произойдет автоматическая вставка буферов ввода-вывода, необходимых для преобразования уровней и усиления сигналов для задействованных пинов ПЛИС.  

* Запустите синтез описания следующей командой tcl, или выбором пунка меню `Synthesize - XST` в окне процессов. 
  
```tcl
process run "Synthesize - XST" -force rerun_all
```

<!-- Допустимые команды можно получить по команде:

```tcl
project get_processes -instance adder
{Back-annotate Pin Locations} 
{Behavioral Check Syntax} 
{Check Syntax} 
{Create Schematic Symbol} 
{Generate IBIS Model} 
{Generate Post-Map Simulation Model} 
{Generate Post-Map Static Timing}
{Generate Post-Place & Route Simulation Model} 
{Generate Post-Place & Route Static Timing} 
{Generate Post-Synthesis Simulation Model} 
{Generate Post-Translate Simulation Model} 
{Generate Programming File} 
{Generate Text Power Report} 
{Implement Design} 
Map 
{Place & Route} 
{Synthesize - XST} 
Translate
``` -->

* Далее откройте синтезированную схему технологического уровня в окне процессов в пунке  `Synthesize - XST / View Technology Schematic`

> **В отчет:** Схему полученного сумматора занесите в отчет.

* В свойствах процесса `Synthesize - XST / Xilinx Specific Options` установите флаг `iobuf` или запустите tcl команду:
* 
```tcl
project set "add i/o buffers" true
``` 

* Запустите синтез описания и сборку проекта следующей командой tcl, или выбором пунка меню `Place & Route` в окне процессов. 
  
```tcl
process run "Place & Route" -force rerun_all
```

* В окне процессов в пункет `Place & Route` выберите пункт `View/Edit Routed Design (FPGA Editor)`

В итоге будет открыто окно редактора FPGA Editor, который позволяет детально изучить и модифицироваать результаты выполнения размещения и трассировки. 

<img src="assets/part1_img2.png" alt="Окно модуля FPGA Editor" style="width:800px;"/>

{:.image-caption}
**Рисунок 5 — Окно модуля FPGA Editor**

* Выберите один из двух конфигурируемых лонических блоков схемы в окне List, и в правом меню выберите пункт `editblock`. Изучите реализованную схему сумматора (пример показан на рисунке 6). 
  
<img src="assets/part1_img3.png" alt="Окно редактора КЛБ модуля FPGA Editor" style="width:800px;"/>

{:.image-caption}
**Рисунок 6 — Окно редактора КЛБ модуля FPGA Editor**

> **В отчет:** Схему сумматора для одного блока SLICEL занесите в отчет (копию экрана PrtSc).


#### 2.1.2. Статический временной анализ

В практических задачах часто возникает потребность добиться максимальной производительности устройства. Для достижения максимальных допустимых тактовых частот необходимо выполнить статический анализ проекта, выявить наиболее длинную цепь распространнеия сигнала и выполнить ее оптимизацию.

Зачастую выполнение дополнительных этапов оптимизации проекта (например, дополнительный временной анализ в процессе трассировки, такие как т.н. `Extra Implementation Efforts`), не обеспечивают должного результата. Тогда разработчик вынужден изменять код проекта для сокращения критических путей, что приводит к росту тактовой частоты. 

Выполним сборку отладочного проекта сумматора. В проекте используется два счетчика, работающих синхронно в реверсивных режимах друг относительно друга: первый счетчик выполняет инкремент 128-битного значения, в то время как второй счетчик выполняет декремент 128-битного значения. 

В случае соблюдения временных ограничений, сумма двух значений должна выдавать ноль. Однако, при росте частоты может случиться нарушение условий `WNS`, `TNS`, `WHS` или `THS`, что пиведет к ошибочному значению на выходах сумматора. 

В коде проекта будем сравнивать в каждом такте значение суммы с нулем. 

* Создайте директорию проекта `~/lab1/part2`.

#### 2.1.3. Линейные сдвиговые регистры с обратной связью (LFSR)

* Для проверки работоспособности сумматора будем исопльзовать счетчик на основе линейных сдвиговых регистров с обратной связью (Linear Feedback
Shift-Register, LFSR). Отличительной особенностью данного типа счетчиков является формирования счетного значения на основе сдвига разрядов от младшего к старшему в каждом такте. Для перебора всех счетных значений с модулем счета 2<sup>n</sup>-1 (где n - количество битов в регистре) применяется сигнал обратной связи на основе функции XOR (или XNOR) некоторых из разрядов счетчика, являющимися степенями членов неприводимого полина). Например, для полинома порядка `n=168` неприводимый полниом содержит члены со степенями `{168,162,159,152}`.  Поэтому в счетчике LFSR с количеством разрядов `n=168` необходимо в младший разряд сдвигового регистра подавать функцию XOR разрядов 167,161,158,151 (считая рязряды от нуля):

```Verilog
next_q[0] = q[167] ^ q[161] ^ q[158] ^ q[151]; // Обратная связь согласно полиному степени 168
```
При использовании функции XOR значение счетчика 0 (т.е. `{128{1'b0}}`) является недопустимой комбинацией (счетчик должен инициализироваться в начальный момент любым значением, кроме нулевого). При  функции XNOR значение счетчика 0xf...f (т.е. `{128{1'b1}}`) является недопустимой комбинацией и счетчик должен инициализироваться любым значением кроме `{128{1'b1}}`.

Благодаря примитивной структуре, LFSR счетчик обладает высоким быстродействием и используются в различных приложениях, таких как: генерация псевдослучайных чисел, потоковая криптография, тестирование и других. 

В работе [Таблица степеней неприводимых полиномов для обратных связей LFSR4](docs/lfsr_table.pdf) приведены степени полинома для генерации LFSR счечиков от 3 до 786.

В статье [XAPP 052](http://ebook.pldworld.com/_semiconductors/Xilinx/DataSource%20CD-ROM/Rev.6%20(Q1-2002)/appnotes/xapp052.pdf) подробно описаны схемы LFSR счетчика. 

Пример кода LFSR счетчика для n=128 представлен ниже:

```Verilog
//Файл lfsr.v
module lfsr (
  input clk,
  input rstn,
  input en,
  output reg [127:0] q
);

  reg [127:0] next_q;

  always @(posedge clk) begin
    if (!rstn) begin
      q <= {128{1'b1}}; // Инициализация
    end else if (!en) begin
      next_q = q << 1;
      next_q[0] = q[127] ^ q[126] ^ q[125] ^ q[120]; // Обратная связь согласно неприводимому полиному степени 128
      q <= next_q;
    end
  end

endmodule
```

* Модифицируйте разрядность LFSR счетчика для Вашего индвидуального задания.

#### 2.1.4. Индивидуальные задания

| Номер варианта | Разрядность устройства |
|:---:|:---:|
| 1 | 177 |
| 2 | 129 |
| 3 | 178 |
| 4 | 155 |
| 5 | 101 |
| 6 | 187 |
| 7 | 143 |
| 8 | 167 |
| 9 | 112 |
| 10 | 195 |
| 11 | 162 |
| 12 | 171 |
| 13 | 136 |
| 14 | 180 |
| 15 | 107 |
| 16 | 182 |
| 17 | 150 |
| 18 | 164 |
| 19 | 118 |
| 20 | 191 |
| 21 | 171 |
| 22 | 175 |
| 23 | 140 |
| 24 | 104 |
| 25 | 189 |
| 26 | 167 |
| 27 | 173 |
| 28 | 132 |
| 29 | 115 |
| 30 | 198 |
| 31 | 174 |
| 32 | 169 |
| 33 | 146 |
| 34 | 122 |
| 35 | 158 |


#### 2.1.5. Исходные описания основных модулей сумматора

* Создайте описание сумматора, использующее моделируемые задержки распространения сигнала.


```Verilog
//Файл cla_checker.v
module cla_checker #(
  parameter w = 128
)
(
  input 	rstn,
  input 	clk,
  input 	en,
  output reg error
);
  (* KEEP="TRUE" *)(* DONT_TOUCH="TRUE" *) wire [w-1:0] counter0;
  (* KEEP="TRUE" *)(* DONT_TOUCH="TRUE" *) wire [w-1:0] counter1;
  (* KEEP="TRUE" *)(* DONT_TOUCH="TRUE" *) wire[w-1:0] sum;
  wire error_comb;

 //LFSR счетчик и его обратный код
  lfsr lsfr_128(.clk(clk),.rstn(rstn),.en(en),.q(counter0));
  assign counter1 = ~counter0;
  assign #8 sum = counter0 + counter1;
  assign error_comb = (sum != {w{1'b1}});
  
  always @(posedge clk) begin
		if (!rstn) begin
		  error <= 1'b0;
		end
		else if (error_comb) begin
		  error <= 1'b1;
		end
  end

endmodule
```
* Создайте модуль верхнего уровня, в котором инстанцирован менеджер синхросигналов `MMCM_BASE` и схема сброса системы.
  
```Verilog
//Файл cla_top.v
`timescale 1ns / 1ps

module cla_top (
  input  rst,
  input  user_clk, //66MHz MHz
  input  en,
  output error,
  output locked
);

wire int_clk, clk_bufg, clkfbout, clkfbout_bufg;
reg[15:0] logic_resetn;

   MMCM_BASE #(
      .BANDWIDTH("OPTIMIZED"),   // Jitter programming ("HIGH","LOW","OPTIMIZED")
      .CLKFBOUT_MULT_F(15),     // Multiply value for all CLKOUT (5.0-64.0).
      .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (0.00-360.00).
      .CLKIN1_PERIOD(15.15),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      .CLKOUT0_DIVIDE_F(1.0),    // Divide amount for CLKOUT0 (1.000-128.000).
      // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLKOUT6_PHASE(0.0),
      // CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT1_DIVIDE(2),
      .CLKOUT2_DIVIDE(1),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT4_CASCADE("FALSE"), // Cascase CLKOUT4 counter with CLKOUT6 (TRUE/FALSE)
      .CLOCK_HOLD("FALSE"),      // Hold VCO Frequency (TRUE/FALSE)
      .DIVCLK_DIVIDE(1),         // Master division value (1-80)
      .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
      .STARTUP_WAIT("FALSE")     // Not supported. Must be set to FALSE.
   )
   MMCM_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(),     // 1-bit output: CLKOUT0 output
      .CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0 output
      .CLKOUT1(int_clk),     // 1-bit output: CLKOUT1 output
      .CLKOUT1B(),   // 1-bit output: Inverted CLKOUT1 output
      .CLKOUT2(),     // 1-bit output: CLKOUT2 output
      .CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2 output
      .CLKOUT3(),     // 1-bit output: CLKOUT3 output
      .CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3 output
      .CLKOUT4(),     // 1-bit output: CLKOUT4 output
      .CLKOUT5(),     // 1-bit output: CLKOUT5 output
      .CLKOUT6(),     // 1-bit output: CLKOUT6 output
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(clkfbout),   // 1-bit output: Feedback clock output
      .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT output
      // Status Port: 1-bit (each) output: MMCM status ports
      .LOCKED(locked),       // 1-bit output: LOCK output
      // Clock Input: 1-bit (each) input: Clock input
      .CLKIN1(user_clk),
      // Control Ports: 1-bit (each) input: MMCM control ports
      .PWRDWN(1'b0),       // 1-bit input: Power-down input
      .RST(rst),             // 1-bit input: Reset input
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(clkfbout_bufg)      // 1-bit input: Feedback clock input
   );

   // End of MMCM_BASE_inst instantiation
				
	//FB signal			
    BUFG bufgctrl_fb (
      .I(clkfbout),
      .O(clkfbout_bufg)
  );
  
   //Target clock
    BUFG bufgctrl_clk (
      .I(int_clk),
      .O(clk_bufg)
  );

	 //Logic reset
	always @(posedge clk_bufg or negedge locked) begin
		 if (!locked) begin
			  logic_resetn <= 0;
		 end else begin
			  logic_resetn <= {1'b1, logic_resetn [15:1]};
		 end
	end

	// lab_top module
	cla_checker #(.w(128)) 
	cla_inst(
		.rstn(logic_resetn[0]),
		.clk(clk_bufg),
		.en(en),
		.error(error));

endmodule
```

* Создайте файл ограничений `cla.ucf`:

```tcl
## Файл part2.ucf
## X5 / 66MHz
NET "user_clk" LOC = U23;
NET "user_clk" TNM_NET = "userclk";
# 66 Mhz
TIMESPEC ts0 = PERIOD "userclk" 15.15 ns HIGH 50 %;
## Кнопка сброса SW10 (высокий активный уровень)
NET "rst" LOC = H10;
NET "rst" TIG;
## Состояние "Синхросигнал стабилен", Светодиод: north
NET "locked" LOC = AH27;
## Состояние "Ошибка", Светодиод: south
NET "error" LOC = AH28;
## Сигнал "Разрешение работы счетчиков": north
NET "en" LOC = A19;
```

> **В отчет:** Объясните, почему в файле part2.ucf задано ограничение NET "rst" TIG; (игнорировать результаты анализа тайминов для сигнала RST). Выводы занесите в отчет.


Частота синхронизации модуля `cla_checker` определяется по частоте входного синхросигнала (F<sub>user\_clk</sub>=66.6MHz) следующим образом:

```math
F_CLA={Fuser_clk * CLKFBOUT_MULT_F / CLKOUT1_DIVIDE} = {66.6 MHz * 15 / 3} = 333 MHz
```

Параметры `CLKFBOUT_MULT_F(15)` и `CLKOUT1_DIVIDE(3)` заданы в коде модуля `cla_top`.

> **В отчет:** В каких случаях и с помощью какого сигнала происходит сброс модуля cla_checker? Ответ занесите в отчет.

* Создайте скрипт tcl `part2.tcl` испльзую текст `part1.tcl`, в котором измените список исходных фалйов проекта. 
* Создайте проект, запустив скрипт `part2.tcl`.
* Запустите сборку проекта  окне процессов в пунке меню `Generate Programming File` или командой tcl:

```tcl
process run "Generate Programming File" -force rerun_all
```
* В основном окне во вкладке `Design Summary` откройте отчет о результатх статического временного анализа (`Timing Report`).

Основная информация в отчете:
* Резюмированная информация о выполнении временных ограничений (Score, Timing errors и другие)
* Лог сообщений статического временного анализа (Informational messages)
* Перечень заданных временных ограничений (Timing Summary)
* Перечень критических путей (по умолчанию по 3 пути с нарушениями времени Hold, Setup, Switching)

> **В отчет:** Определите тип возникшего нарушения временных ограничений: Setup или Hold? Занесите в отчет перечень сигналов и компонент, входящий в самую длинную комбинационную цепь (первую из трех). Содержимое секции Timing summary занесите в отчет. 

* Установите настроечную константу разрядности `w` для модуля cla_chacker в соответствии с индивидуальным вариантом по таблице Индивидуальных заданий.


#### 2.1.6. Тестирование сумматора на ПЛИС

* Подбирая параметры `CLKFBOUT_MULT_F` и `CLKOUT1_DIVIDE`, добейтесь максимальной частоты `F_CLA_max`, при которой отсутстуют нарушения временных ограничений.

* Загрузите проект на плату ML605 (рисунок 7). Проверьте работоспособность сумматора при заданных Вами параметрах.
  
<img src="assets/ml605.png" alt="Отладочная плата Xilinx ML605" style="width:800px;"/>

{:.image-caption}
**Рисунок 7 — Отладочная плата Xilinx ML605**

>**В отчет:** Параметры и выводы о работоспособности сумматора занесите в отчет.

### 2.2. Генерация ядер логического анализатора для внутрирсхемной отладки

При реализации устройств, активно взаимодействующих через внешние порты, поведенческое моделирование не всегда позволяет отладить устройство. В таких случаях применяют внутрисхемную отладку. 

Внутрисхемная отладка (In-System Debugging, ISD) позволяет анализировать сигналы и поведение проекта на ПЛИС непосредственно на целевом устройстве, без необходимости использования внешних эмуляторов или моделирования.  ChipScope — это один из популярных инструментов внутрисхемной отладки для ПЛИС Xilinx, предоставляющий широкие возможности для анализа сигналов.  В данной лабораторной работе будут рассмотрены его основные возможности.

Для ПЛИС Xilinx и САПР ISE 14.7 имеется возможность инстанцирования в проект специальных средств внутрисхемной отладки: 
* **ILA (Integrated Logic Analyzer)** -это IP ядро логического анализатора, встраиваемое непосредственно в проект на ПЛИС, и использующий цепи JTAG для передачи данных на хост. Анализатор позволяет захватывать и анализировать сигналы  в реальном времени, без необходимости использования внешнего оборудования. Частота работы позволяет использовать ILA практичесик для любых проектов ПЛИС.  
* **ICON (Integrated Connectivity)** - это IP-ядро, обеспечивающее высокоскоростное соединение между ПЛИС и хостом для передачи данных отладки. 
* **VIO (Virtual I/O)** - это IP ядро, позволяющее изменять сигналы внутри ПЛИС с использованием графического приложения. Также VIO позволяет отображать внутренние сигналы ПЛИС. 

Перед началом отладки необходимо определить, какие сигналы будут анализироваться и передать их на Интегрированный логический анализатор ILA.  Триггеры позволяют захватывать данные только при наступлении определенных событий, что значительно упрощает анализ больших объемов данных.  Можно настроить множество различных условий триггеров, включающих логические комбинации сигналов и временные параметры.

* Создайте новое IP ядро ILA. Для этого в меню `Project` выберите пункт `New Source`. 
* Далее выберите тип нового модуля: `IP (Core Generator & Architecture Wizard)`. 
* Задайте имя ядра, например `ila`. Нажмите `Next`. 
* В поле `Search IP Catalog` введите текст "ILA", Нажмите `Enter`. Выберите предложенный вариант ядра. Нажмите `Next`, `Finish`.
* На первой странице настроек укажите количество портов `Number of Trigger Ports` = 5
* На второй, третьей и четвертой страницах параметров укажите заданный параметр "Разрядность йстройства", например  `Trigger Port Width` = 177. 
* На пятой и шестой страницах параметров (порты 3 и 4), укажите параметр  `Trigger Port Width` = 1 (для сигналов `error_comb` и `error`). 
* Аналогичным образом создайте IP ядро ICON с именем `icon`. Все настройки можно оставить без изменений (`Control port`: 1).
* Добавьте в модуль проекта `cla_checker` созданные IP ядра:

```Verilog
   //Файл cla_checker.v
  wire[35:0] control0; 
  icon icon_inst (
	  .CONTROL0(control0) 	// INOUT BUS [35:0]
  );

  ila ila_inst (
	   .CONTROL(control0),  // INOUT BUS [35:0]
	   .CLK(clk), 			    // IN
	   .TRIG0(counter0), 	  // IN BUS [127:0]
	   .TRIG1(counter1), 	  // IN BUS [127:0]
	   .TRIG2(sum), 		    // IN BUS [127:0]
	   .TRIG3(error_comb),	// IN BUS [0:0]
	   .TRIG4(error) 		    // IN BUS [0:0]
  );
endmodule
```

* Выполните генерацию файла прошивки ПЛИС и конфигурацию ПЛИС.
* Запустите программу ChipScope (рисунок 8). Программа доступна в перечне приложений ОС Ubuntu Linux.

<img src="assets/part2_img1.png" alt="Окно программы логического анализатора ChipScope" style="width:800px;"/>

{:.image-caption}
**Рисунок 8 — Окно программы логического анализатора ChipScope**


* Выполните обнаружение устройств и сканирование JTAG цепочки (пункт меню `JTAG Chain`)
* Получите диаграмму корректно работающего устройства (WaveForm). 
  
> **В отчет:** Снимок экрана программы ChipScope занесите в отчет.

* Увеличьте тактовую частоту синхронизации `F_CLA_max` в 1.5-2 разра с помощью параметров `CLKFBOUT_MULT_F`/`CLKOUT1_DIVIDE`.
* Выполните сборку проекта. Выполните прошивку ПЛИС.
* Для порта TRIG3 укажите в окне `Trigger Setup` тип триггерного события "1". Запустите триггерный режим логического анализатора. 
* Получите диаграмму некорректно работающего устройства.
  
> **В отчет:** Снимок  экрана программы ChipScope для некорректно работающего проекта занесите в отчет.

  
### 2.3. Исследование работы конвейерного сумматора с передачей переноса по цепочке замкнутых ключей (CLA)

#### 2.3.1. Разработка описания конвейерного сумматора на языке Verilog

Конвейеризация существенно усложняет разработку устройств. При описании конвейера приходится манипулировать группами разрядов исходных операндов, что наиболее лаконично делать с помощью массивов. Если же ширина операндов на различных стадиях отличается, то массивы должны иметь элементы различной длины. Также необходимо формировать массивы констант, что не поддерживается в языках VHDL и Verilog. 
Тем не менее, возможно свести из шин различной размерности к массиву шин одинаковой размерности, что, однако, запутывает код.

Синтаксис языка SystemVerilog более разнообразен и выразителен, поэтому конвейерные устройства лучше описывать на данном язые. В данной лабораторной работе, тем не менее, мы будем использовать САПР Xilinx ISE 14.7, которая не поддерживает язык System Verilog.  

* Создайте в директории `~/lab1` описания модулей:
  
```Verilog
//Файл cla_pipelined.v
module pipelined_adder #(
  parameter w = 128, // Ширина данных
  parameter s = 4    // Количество ступеней конвейера
) (
  input clk,                // Тактовый сигнал
  input rstn,               // Сброс (активен низкий)
  input [w-1:0] op1,        // Операнд 1
  input [w-1:0] op2,        // Операнд 2
  input valid_op1,          // Сигнал готовности операнда 1
  input valid_op2,          // Сигнал готовности операнда 2
  output reg [w-1:0] res,   // Результат сложения
  output reg valid           // Сигнал готовности результата
);

  // Ширина каждой ступени конвейера
  localparam [s*32-1:0] stage_widths = {32'd34, 32'd32, 32'd32, 32'd30};

  // Макрос для доступа к ширине ступени
  `define wth(stage) stage_widths[32*stage+:32]

  // Функция для вычисления базового адреса для данной ступени
  function integer base;
    input integer stage;
    begin
      base = 0;
      for (stage = stage; stage > 0; stage = stage - 1) begin
        base = base + stage_widths[32*(stage-1)+:32];
      end
    end
  endfunction

  // Функция для получения ширины ступени
  function integer width;
    input integer stage;
    begin
      width = stage_widths[32*stage+:32];
    end
  endfunction

  // Регистры для хранения данных на каждой ступени конвейера
  reg [w-1:0] stage_reg [0:s-1];
  // Комбинационные сигналы для каждой ступени
  wire [w-1:0] stage_comb [0:s-1];
  // Регистры для хранения операндов на каждой ступени
  reg [w-1:0] stage_op1 [0:s-1];
  reg [w-1:0] stage_op2 [0:s-1];
  // Регистры для сигналов готовности на каждой ступени
  reg [s-1:0] valid_reg;
  // Регистры для переноса на каждой ступени
  reg [s:0] c_reg;
  // Комбинационные сигналы для переноса
  wire [s:0] c_comb;
  // Сигналы переноса из каждой ступени
  wire [s-1:0] f; 
  integer i;
  genvar k;

  // Инициализация регистров
  initial begin
    for (i = 0; i < s; i = i + 1) begin
      stage_reg[i] <= {w{1'b0}};
      valid_reg[i] <= 1'b0;
      stage_op1[i] <= {w{1'b0}};
      stage_op2[i] <= {w{1'b0}};
      res <= {w{1'b0}};
    end
  end

  // Загрузка операндов в первую ступень конвейера
  always @(*) begin
    stage_op1[0] <= op1;
    stage_op2[0] <= op2;
  end

  // Генерация ступеней конвейера
  generate
    for (k = 0; k < s; k = k + 1) begin : adder
      // Сложение на k-ой ступени
      assign {c_comb[k+1], stage_comb[k][base(k)+:`wth(k)], f[k]} = {1'b0, stage_op1[k][base(k)+:`wth(k)], c_reg[k]} + {1'b0, stage_op2[k][base(k)+:`wth(k)], c_reg[k]};

      // Тактируемый процесс для k-ой ступени
      always @(posedge clk) begin: stage_reg_inst
        if (~rstn) begin // Сброс
          for (i = 1; i < s; i = i + 1) begin
            stage_reg[i][base(k)+:`wth(k)] <= {(`wth(k)){1'b0}};
          end
        end else begin
          // Запись результата в регистр текущей ступени
          stage_reg[0][base(k)+:`wth(k)] <= stage_comb[0][base(k)+:`wth(k)];
          // Передача данных между ступенями
          for (i = 1; i < s; i = i + 1) begin
            if (valid_reg[i-1]) begin
              if (i == k)
                stage_reg[i][base(k)+:`wth(k)] <= stage_comb[i][base(k)+:`wth(k)];
              else
                stage_reg[i][base(k)+:`wth(k)] <= stage_reg[i-1][base(k)+:`wth(k)];
            end
          end
        end
      end
    end
  endgenerate

  // Тактируемый процесс для управления конвейером и выдачи результата
  always @(posedge clk) begin
    if (~rstn) begin // Сброс
      valid <= 1'b0;
      res <= {w{1'b0}};
      valid_reg[i] <= {s{1'b0}};
      c_reg <= {s{1'b0}};
      for (i = 1; i < s; i = i + 1) begin
        stage_op1[i] <= {w{1'b0}};
        stage_op2[i] <= {w{1'b0}};
      end
    end else begin
      valid_reg[0] <= valid_op1 & valid_op2; // Сигнал готовности для первой ступени
      // Распространение сигнала готовности и переноса по ступеням конвейера
      for (i = 1; i < s; i = i + 1) begin
        valid_reg[i] <= valid_reg[i-1];
        c_reg[i] <= c_comb[i];
        stage_op1[i] <= stage_op1[i-1];
        stage_op2[i] <= stage_op2[i-1];
      end
      res <= stage_reg[s-1]; // Выдача результата из последней ступени
      valid <= valid_reg[s-1]; // Сигнал готовности результата
    end
  end

endmodule
```
 

* Файл `cla_checker_pipelined.v` для генерации счетных значений и передачи из в сумматор представлен ниже:

```Verilog
//Файл cla_checker_pipelined.v
module cla_checker_pipelined #(
  parameter w = 128
)
(
  input 	rstn,
  input 	clk,
  input 	en,
  output reg error
);
  (* KEEP="TRUE" *)(* DONT_TOUCH="TRUE" *) wire [w-1:0] counter0;
  (* KEEP="TRUE" *)(* DONT_TOUCH="TRUE" *) wire [w-1:0] counter1;
  (* KEEP="TRUE" *)(* DONT_TOUCH="TRUE" *) wire[w-1:0] sum;
  wire error_comb;
  wire sum_valid;
  //LFSR     
  lfsr lfsr_inst(.clk(clk),.rstn(rstn),.en(en),.q(counter0));
  assign counter1 = ~counter0;
  assign error_comb = sum_valid & (sum != {w{1'b1}});

  //   
  pipelined_adder #(
		.w(128),       //  
		.s(4)          //   
  ) pipelined_adder_inst (
		.clk(clk),
		.rstn(rstn),
		.op1(counter0),
		.op2(counter1),
		.valid_op1(~en),
		.valid_op2(~en),
		.res(sum),
		.valid(sum_valid)
  );

  always @(posedge clk) begin
		if (!rstn) begin
		  error <= 1'b0;
		end
		else if (error_comb) begin
		  error <= 1'b1;
		end
  end

  wire[35:0] control0; 
  icon icon_inst (
	  .CONTROL0(control0) 	// INOUT BUS [35:0]
  );

  ila ila_inst (
	   .CONTROL(control0),  // INOUT BUS [35:0]
	   .CLK(clk), 			    // IN
	   .TRIG0(counter0), 	  // IN BUS [127:0]
	   .TRIG1(counter1), 	  // IN BUS [127:0]
	   .TRIG2(sum), 		    // IN BUS [127:0]
	   .TRIG3(error_comb),	// IN BUS [0:0]
	   .TRIG4(error) 		    // IN BUS [0:0]
  );
	
endmodule
```

* В исходном файле `cla_top.v` измените имя модуля на `cla_checker_pipeline`.
* Создайте файл теста модуля `cla_top.v`. Выполните моделирование. Удостоверьтесь в корректности работы устройства.

> Результаты моделирования занесите в отчет.

* Файл ограничений можно использовать из 2-й части практикума (`part2.ucf`)
* Измените скрипт tcl для создания проекта. Создайте проект.

#### 2.3.2. Оптимизация конвейерного сумматора


* Для индивидуального задания части 2 (разрядность устройства) получите значения `F_CLA_max` для количества стадий конвейерного сумматора от 2-х до 5-ти.
* Постройте график зависимости максимальной частоты устройства от количества стадий конвейера `F_CLA_max(Количество стадий конвейера)` для варианта с латентностью 1 (получена ранее в пункте 2.1.6) и для четырех конвейерных вариантов.
* 
> **В отчет:**  Занесите в отчет: 
> * Исходные параметры для конвейеризации CLA. 
> * Обобщенные результаты статического временного анализа конвейерных вариантов.
> * График зависимости `F_CLA_max(Количество стадий конвейера)`.

