# Генератор микропрограммных автоматов microcode_generator

## Описание

Программа преобразует текстовое описание детерменированного автомата в код на языке VHDL, и генерирует файл инициализации памяти микропрограмм и файл памяти адресов микропрограмм.  Три результирующих файла являются синтезируемыми и могут быть включены в проект HDL.

Вместе с этим генерируется файл в формате DOT для визуализации графа переходов состояний. 

## Команды для сборки проекта


Для сборки проекта: 

```
make
```

Для сборки тестового проекта, который находится в папке example:

```
make run
```

## Пример графа переходов состояний автомата

Пример показан ниже:

![Пример графа переходов состояний автомата](example/example_fsm.svg)

**Пример графа переходов состояний автомата**


## Структура микропрограммного автомата

В микропрограммном автомате возможно указать неограниченное количество состояний, входных и выходных сигналов, а также количество микропрограмм.
Однако, при росте количества переходов из одного состояния увеличивается сложность схем сравнения, и работа автомата замедляется. 

Пример описания автомата показан ниже: 

```py

/Описание управляющих сигналов автомата
@CONTROL
	control0;
	control1;
	control2;
	control3;
	control4;
	mpu_ready;
	/Состояние сигналов по умолчанию: 1`b0

/Описание осведомительных сигналов автомата
@FEEDBACK
	feedback0;
	feedback1;
	feedback2;
	feedback3;
	feedback4;


/Сигналы кода команды
@CMD
	cmd0;
	cmd1;
	cmd2;
	cmd3;
	cmd4;

/Сигнал разрешения запуска микропрограммы
@RUN
	start;


/Начальное состояние
IDLE0:
	control0=0;
	control1=0;
	control2=0;
	control3=0;
	control4=0;
	mpu_ready=1;

/Описание микропрограмм
/0x00 Микропрограмма 0
@IF (cmd4=0&cmd3=0&cmd2=0&cmd1=0&cmd0=0&start=1) => EX_0;
/0x01 Микропрограмма 1
@IF (cmd4=0&cmd3=0&cmd2=0&cmd1=0&cmd0=1&start=1) => EX_1;
/0x02 Микропрограмма 2
@IF (cmd4=0&cmd3=0&cmd2=0&cmd1=1&cmd0=0&start=1) => EX_2;
/0x02 Микропрограмма 31
@IF (cmd4=1&cmd3=1&cmd2=1&cmd1=1&cmd0=1&start=1) => EX_1F;

/Переход по умолчанию
@DEFAULT => IDLE0;

/////////////////////////////
/	   Микропрограмма 0  	/
/////////////////////////////

EX_0: 

	control4=0;
	control3=0;
	control2=0;
	control1=0;
	control0=1;

	@DEFAULT => EX_0_STATE1;

EX_0_STATE1:  

	@IF (feedback0=1) => IDLE0;
	@DEFAULT => EX_0_STATE1;

/////////////////////////////
/	   Микропрограмма 1  	/
/////////////////////////////

EX_1: 

	control4=0;
	control3=0;
	control2=0;
	control1=0;
	control0=1;

	@DEFAULT => EX_1_STATE1;

EX_1_STATE1:  /Множественные переходы

	@IF (feedback2=0 & feedback1=0 & feedback0=1) => EX_1_FB1;
	@IF (feedback2=0 & feedback1=1 & feedback0=0) => EX_1_FB2;
	@IF (feedback2=0 & feedback1=1 & feedback0=1) => EX_1_FB3;
	@IF (feedback2=1 & feedback1=0 & feedback0=0) => EX_1_FB4;
	@DEFAULT => EX_1_STATE1;

EX_1_FB1: /

	control4=0;
	control3=0;
	control2=0;
	control1=1;
	control0=0;

	@DEFAULT => IDLE0;

EX_1_FB2: /

	control4=0;
	control3=0;
	control2=1;
	control1=0;
	control0=0;

	@DEFAULT => IDLE0;

EX_1_FB3: /

	control4=0;
	control3=1;
	control2=0;
	control1=0;
	control0=0;

	@DEFAULT => IDLE0;

EX_1_FB4: /

	control4=1;
	control3=0;
	control2=0;
	control1=0;
	control0=0;

	@DEFAULT => IDLE0;



/////////////////////////////
/	   Микропрограмма 2  	/
/////////////////////////////

EX_2: /

	control4=0;
	control3=0;
	control2=0;
	control1=1;
	control0=1;

	@DEFAULT => EX_2_STATE1;

EX_2_STATE1:  /Множественные переходы

	@IF (feedback2=0 & feedback1=0 & feedback0=1) => EX_2_FB1;
	@IF (feedback2=0 & feedback1=1 & feedback0=0) => EX_2_FB2;
	@IF (feedback2=0 & feedback1=1 & feedback0=1) => EX_2_FB3;
	@IF (feedback2=1 & feedback1=0 & feedback0=0) => EX_2_FB4;
	@DEFAULT => EX_2_STATE1;

EX_2_FB1: /

	control4=1;
	control3=1;
	control2=1;
	control1=0;
	control0=1;

	@DEFAULT => IDLE0;

EX_2_FB2: /

	control4=1;
	control3=1;
	control2=0;
	control1=1;
	control0=1;

	@DEFAULT => IDLE0;

EX_2_FB3: /

	control4=1;
	control3=0;
	control2=1;
	control1=1;
	control0=1;

	@DEFAULT => IDLE0;

EX_2_FB4: /

	control4=0;
	control3=1;
	control2=1;
	control1=1;
	control0=1;

	@DEFAULT => IDLE0;


/////////////////////////////
/	   Микропрограмма 1F  	/
/////////////////////////////

EX_1F: /

	control4=1;
	control3=1;
	control2=1;
	control1=1;
	control0=1;

	@DEFAULT => EX_1F_STATE1;

EX_1F_STATE1:  /

	@IF (feedback4=1) => IDLE0;
	@DEFAULT => EX_1F_STATE1;

```


## Структура HDL описания

Синтезируеое описание автомата является классической схемой микропрограммного автомата:

```bash
--**********************************************************************************************************         
--      
--      MC_G      - Group count. Define the number of transitions from one state 
--      MC_FBS    - The number of "feedback" signals. Define the Mask word weight.
--      MC_ADR    - The number of MCROM address word weight. State count is less than 2**MC_ADR  
--      MC_C      - Microcommand control word 
--      CMD_C     - Command count
--                     
--**********************************************************************************************************         
--                                             
--            /-----------------------------<<-NEXT ADDRESS-<<-------------------------------------\
--            |                                                                                    |   
--            |            FIELD# IN DOUT                                                          |
--            |                    \                           RST >--\                            |
--            |                     \  JUMP_ADR_0                    --o--                         |
--            |                      2/-----------------------------|  R  |                        |
--            |    -------------      |FBS_MASK_0&EN     -----      |     |                        |
--            |   |    MCROM    |    1*-----------------|M    |     |  &  |--                      |
--            |   |             |     |FBS_TAMPLATE_0   |     |     |     |  |                     |
--            \---| A           |    0*-----------------|T   F|--*--|     |  |       ---           |
--                |             |     |                 |     |  |   -----   \------|   |          |
--              o-| DIN    DOUT |->>--|         FBS >---|F   *|  |        ...       |   |          |
--                |             |     |JUMP_ADR_1        -----   |   -----   /------| 1 |--\       | 
--   RST >-->   o-| EN          |    5*--------------------------O--|     |  |      |   |  |       |
--                |       CLK   |     |FBS_MASK_1&EN     -----   |  |     |  |    /-|   |  |       |
--                 ------/------     4*-----------------|M    |  |  |  &  |--/    |  ---   |       |
--   CLK >--------------/             |FBS_TAMPLATE_1   |     |  |  |     |       |   /    |       |
--                                   3*-----------------|T   F|*-O--|  R  |       |  bit   |       |
--                                    |                 |     || |   --o--        |  by    |       |
--   FBS >-->                         |         FBS >-/-|F   *|| |      \--< RST  |  bit   | |\    |
--                                    |              /   ----- | |                |        | | \   |
--                                    |         MC_FBS         | |    ---         |        | |  \  |
--                                    |                        | \---|   |   ---  |        \-|0  | |
--                                    *-   ...                 \-----| 1 |o-|   | |          |MUX|-/
--                                    *- ...      --"--        ...---|   |  |   | |        /-|1  |
--                                    *-   ...                        ---   | & |-/        | | A/
--                                    |                                     |   |          | | /
--                                   6*------>>-ADR @ELSE->>----/-----------|   |          | |/|
--                                    |                        /             ---           |   |
--                                   7\----> MC_C            MC_ADR                        |   |
--                                    MICROCOMMAND                                         |   |
--      CLK >------------                                                                  |   |
--                       \                                                                 |   |
--                    ----/-----                                                           |   |
--                   |   CLK    |                                                          |   |     
--                   |          |                      FIRST COMMAND ADDRESS               |   |
--      CMD >--------|A  CMDROM |----------------------------------------------------------/   |
--                   |          |                                                              |
--                   |          |                                                              |
--                    ----------                                                               |
--                                                     COMMAND ENABLE                          |
--      RUN >----------------------------------------------------------------------------------/
--
--
--
--   * - F= and (!((Ti = Fi) and Mi))
--
--********************************************************************************************************** 

```

