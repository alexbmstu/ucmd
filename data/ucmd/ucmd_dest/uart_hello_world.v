//**********************************************************************************************************
//**********************************************************************************************************
//      Bauman state Tech University. Computer systems and Network Department. Alex Popov(c)
//**********************************************************************************************************         
//      This design describes microprogramme statemachine, which can be realised both as Block and 
//      Distributed ROM, depends on synthesis options. 
//**********************************************************************************************************         
//      
//      ucmd_g      - Group count. Define the number of transitions from one state 
//      ucmd_fbs    - The number of "feedback" signals. Define the Mask word weight.
//      ucmd_adr    - The number of ucmdRAM address word weight. State count is less than 2**ucmd_adr  
//      ucmd_c      - Microcommand control word 
//      cmd_c     - Command count
//                     
//**********************************************************************************************************         
//                                             
//      /----------------------------------<<-NEXT ADDRESS-<<-------------------------------------\
//      |                                                                                          |   
//      |                  FIELD# IN DOUT                                                          |
//      |                           \                          rst >--\                            |
//      |                            \ JUMP_ADR_0                    --o--                         |
//      |                            2/-----------------------------|  R  |                        |
//      |    ------------------       |fbs_MASK_0&EN     -----      |     |                        |
//      |   |     ucmdRAM      |     1*-----------------|M    |     |  &  |--                      |
//      |   |                  |      |fbs_TAMPLATE_0   |     |     |     |  |                     |
//      \---| A                |     0*-----------------|T   F|--*--|     |  |       ---           |
//          |                  |      |                 |     |  |   -----   \------|   |          |
//        o-| WR_PORT  RD_PORT |->>---|         fbs >---|F   *|  |        ...       |   |          |
//          |                  |      |JUMP_ADR_1        -----   |   -----   /------| 1 |--\       | 
//     o-   | WE               |     5*--------------------------O--|     |  |      |   |  |       |
//          |       clk        |      |fbs_MASK_1&EN     -----   |  |     |  |    /-|   |  |       |
//           -----------|------      4*-----------------|M    |  |  |  &  |--/    |  ---   |       |
//   clk >--------------              |fbs_TAMPLATE_1   |     |  |  |     |       |   /    |       |
//                                   3*-----------------|T   F|*-O--|  R  |       |  bit   |       |
//                                    |                 |     || |   --o--        |  by    |       |
//   fbs >-->                         |         fbs >-/-|F   *|| |      \--< rst  |  bit   | |\    |
//   rst >-->                         |              /   ----- | |                |        | | \   |
//                                    |         ucmd_fbs       | |    ---         |        | |  \  |
//                                    |                        | \---|   |   ---  |        \-|0  | |
//                                    *-   ...                 \-----| 1 |o-|   | |          |MUX|-/
//                                    *- ...      --"--        ...---|   |  |   | |        /-|1  |
//                                    *-   ...                        ---   | & |-/        | | A/
//                                    |                                     |   |          | | /
//                                   6*------>>-ADR @ELSE->>----/-----------|   |          | |/|
//                                    |                        /             ---           |   |
//                                   7\----> ucmd_c            ucmd_adr                    |   |
//                                    MICROCOMMAND                                         |   |
//      clk >------------                                                                  |   |
//                       \                                                                 |   |
//                    ----/-----                                                           |   |
//                   |   clk    |                                                          |   |     
//                   |          |                      FIrst COMMAND ADDRESS               |   |
//      cmd >--------|A  cmdROM |----------------------------------------------------------/   |
//                   |          |                                                              |
//                   |          |                                                              |
//                    ----------                                                               |
//                                                     COMMAND ENABLE                          |
//      run >----------------------------------------------------------------------------------/
//
//
//
//   * - F= and (!((Ti = Fi) and Mi))
//
//********************************************************************************************************** 
//
//   Control signals description:
//
//    UC(10) - wvalid
//    UC(9) - rready
//    UC(8) - putchar7
//    UC(7) - putchar6
//    UC(6) - putchar5
//    UC(5) - putchar4
//    UC(4) - putchar3
//    UC(3) - putchar2
//    UC(2) - putchar1
//    UC(1) - putchar0
//    UC(0) - echo
        
//
//   Feedback signals description:
//
//    FBS(8) - wready
//    FBS(7) - getchar7
//    FBS(6) - getchar6
//    FBS(5) - getchar5
//    FBS(4) - getchar4
//    FBS(3) - getchar3
//    FBS(2) - getchar2
//    FBS(1) - getchar1
//    FBS(0) - getchar0

//
//   Command signals description:
//
//    CMD(0) - cmd0

//
//   Command enable signal description:
//
//    run - rvalid

//
//   states description:
//
//    State:IDLE0 - #0
//    State:hello - #1
//    State:H - #2
//    State:echo - #3
//    State:H_w - #4
//    State:e - #5
//    State:e_w - #6
//    State:l0 - #7
//    State:l0_w - #8
//    State:l1 - #9
//    State:l1_w - #10
//    State:o0 - #11
//    State:o0_w - #12
//    State:space - #13
//    State:space_w - #14
//    State:W - #15
//    State:W_w - #16
//    State:o1 - #17
//    State:o1_w - #18
//    State:r - #19
//    State:r_w - #20
//    State:l2 - #21
//    State:l2_w - #22
//    State:d - #23
//    State:d_w - #24
//    State:yeah - #25
//    State:yeah_w - #26
//    State:end - #27

//
//**********************************************************************************************************

//Если необходимо внутрисхемная отладка
//`define chipscope
//`define debug_ucmd
//Универсальные модули миркопрограммного автомата
`ifndef ucmd_carry4
`define ucmd_carry4

//Модуль ucmd_fsm
module ucmd_fsm #( 
    parameter ucmd_g             = 1, 
    parameter ucmd_fbs           = 9, 
    parameter ucmd_adr           = 5, 
    parameter ucmd_c             = 11, 
    parameter cmd_c              = 1,
    parameter ucmdRAM_data_w     = 32,
    parameter ucmdRAM_adr_w      = 6,
    parameter ucmdARAM_data_w    = 5,
    parameter ucmdARAM_adr_w     = 1,
    parameter mcmem_file         = "",
    parameter adrmem_file         = "",
    parameter ucmd_ram_type      = "sync",
    parameter control_type       = "carry4", //carry4, lut
    parameter fpga_type          = "virtex"  //virtex, ultrascale
)( 
    //ucmd signals
    input  wire                            rst, 
    input  wire                            clk, 
    input  wire [cmd_c-1:0]                cmd, 
    input  wire                            run, 
    input  wire [ucmd_fbs-1:0]             fbs, 
    output wire [ucmd_c-1:0]               ucmd, 
    output wire                            busy, 
    output wire [ucmd_adr-1:0]             ucmd_state,
    //ucmdRAM signals 
    input  wire [ucmdRAM_data_w-1:0]       ucmdRAM_data,
    input  wire [ucmdRAM_adr_w-1:0]        ucmdRAM_adr,
    input  wire                            ucmdRAM_we,
    //ucmdARAM signals 
    input  wire [ucmdARAM_data_w-1:0]      ucmdARAM_data,
    input  wire [ucmdARAM_adr_w-1:0]       ucmdARAM_adr,
    input  wire                            ucmdARAM_we    
); 
    // Константы:
    localparam integer term_width = ucmd_fbs+ucmd_fbs+ucmd_adr+1;
    localparam integer ucmd_ctl_width = ucmd_g*term_width+ucmd_c+ucmd_adr; 
    localparam integer ucmd_width = ucmdRAM_data_w * ((ucmd_ctl_width + ucmdRAM_data_w -1) / ucmdRAM_data_w); //кратно wport_data_w
    localparam integer IDLE = 0;
    genvar i,j,k; 
    //Одна запись в микрорпограммном ОЗУ
    wire [ucmd_width-1:0] micro_command; 
    // Адрес в микропрограммном ОЗУ 
    wire [ucmd_adr-1:0] micro_command_address; 
    wire [ucmd_adr-1:0] micro_command_address_next; 
    reg [ucmd_adr-1:0] micro_command_address_comb; 
    reg [ucmd_adr-1:0] micro_command_address_reg; 
    wire [ucmd_adr-1:0] first_micro_command_adr; 
    wire [ucmd_g-1:0] ucmd_term_en;
    // Сигнал ELSE 
    wire [ucmd_adr-1:0] ucmd_else_adr; 
    wire ucmd_else_en;
    //Сигналы маскирования адресов
    wire [ucmd_adr-1:0] ucmd_adr_mask[0:ucmd_g];
    wire [ucmd_g-1:0] ucmd_adr_en;
    wire isin_idle_state;
    
    // Микропрограммное ОЗУ: 
    dualport_ram # (
        .rd_dataw(ucmd_width),
        .wr_dataw(ucmdRAM_data_w),
        .rd_addrw(ucmd_adr),
        .wr_addrw(ucmdRAM_adr_w),
        .filename(mcmem_file),
        .rd_port(ucmd_ram_type),
        .fpga_type(fpga_type)
      )
      inst_ucmd_ram_hello (
        .clk(clk),
        .wr_addr(ucmdRAM_adr),
        .wr_data(ucmdRAM_data),
        .we(ucmdRAM_we),
        .rd_addr(micro_command_address),
        .rd_data(micro_command)
      );    

    //Память адресов микропрограмм: 
    dualport_ram # (
        .rd_dataw(ucmd_adr),
        .wr_dataw(ucmdARAM_data_w),
        .rd_addrw(cmd_c),
        .wr_addrw(ucmdARAM_adr_w),
        .filename(adrmem_file),
        .rd_port("async"),
        .fpga_type(fpga_type)
      )
      inst_ucmd_adrram_hello (
        .clk(clk),
        .wr_addr(ucmdARAM_adr),
        .wr_data(ucmdARAM_data),
        .we(ucmdARAM_we),
        .rd_addr(cmd),
        .rd_data(first_micro_command_adr)
      );    

    // Логика формирования ucmd, ucmd_state, переходов и т.д. 
    assign ucmd_state = micro_command_address; //Состояние автомата для отладки
    assign ucmd = micro_command[ucmd_g*term_width+ucmd_adr+ucmd_c-1 : ucmd_g*term_width+ucmd_adr]; //Управляющая часть микрокоманды

    // Сигналы результатов сравнения для каждой группы

    generate 
        if (control_type=="carry4") begin
            //Оределение бит адрес следующей микрокоманды с использованием CARRY4 цепочек:
            ucmd_carry4 #(.ucmd_g(ucmd_g), .ucmd_adr(ucmd_adr), .ucmd_fbs(ucmd_fbs)) ucmd_carry4_hello_inst (
                .ucmd(micro_command[ucmd_g*term_width+ucmd_adr-1:0]), .fb(fbs), .result_address(micro_command_address_next)
            );

        end else begin
            //Оределение бит адрес следующей микрокоманды с использованием LUT логики:
            for (i=0; i<ucmd_g; i=i+1) begin : ucmd_adr_en_gen 
                wire [ucmd_fbs-1:0] fbsi_value = micro_command[i*term_width+1 +: ucmd_fbs];
                wire [ucmd_fbs-1:0] fbsi_mask  = micro_command[i*term_width+ucmd_fbs+1 +: ucmd_fbs];
                assign ucmd_term_en[i] = micro_command[i*term_width];
                assign ucmd_adr_en[i] = ( ~|((fbs ^ fbsi_value) & fbsi_mask) ) & ucmd_term_en[i];
                assign ucmd_adr_mask[i] = micro_command[i*term_width+2*ucmd_fbs+1 +: ucmd_adr] & {(ucmd_adr){ucmd_adr_en[i]}};
            end 
            //Адрес @else
            assign ucmd_else_en = ~|ucmd_adr_en;
            assign ucmd_else_adr = micro_command[ucmd_g*term_width +: ucmd_adr] & {(ucmd_adr){ucmd_else_en}};
            assign ucmd_adr_mask[ucmd_g] = ucmd_else_adr;
            //Оределение бит адрес следующей микрокоманды:
            for (j=0; j<ucmd_adr; j=j+1) begin : ucmd_adr_gen
                    wire [ucmd_g:0] adr_bit; 
                    for (k=0; k<=ucmd_g; k=k+1) begin : ucmd_adr_bit_gen 
                        assign adr_bit[k] = ucmd_adr_mask[k][j];
                    end
                    assign micro_command_address_next[j] = |adr_bit;
            end 
        end
    endgenerate 

    assign busy = ~isin_idle_state;
    
    //Оределение бит адрес первой микрокоманды:
    generate 
        assign isin_idle_state = (micro_command_address_reg == IDLE);
        if (ucmd_ram_type=="sync")
            assign micro_command_address = micro_command_address_comb;
        else 
            assign micro_command_address = (rst || run) ? 0 : micro_command_address_reg;
    endgenerate 

    //Для ожидания в состоянии #0 (IDLE) нужен дополнительный триггер
    always @(posedge clk) begin
        if (rst)
            micro_command_address_reg = 0;
        else begin
            micro_command_address_reg = micro_command_address_comb;
        end 
    end

    //Формирование адреса следующей микрокоманды: 
    always @* begin
        if (rst) begin
            micro_command_address_comb = 0;
        end
        else begin
            if (isin_idle_state) begin
                if (run)
                    micro_command_address_comb = first_micro_command_adr;
                else 
                    micro_command_address_comb = 0;
            end
            else begin
                micro_command_address_comb = micro_command_address_next;
            end
        end
    end
 
endmodule

//Двухпортовая память RAM
module dualport_ram #(
    parameter rd_dataw = 16,   //   
    parameter wr_dataw = 8,    //   
    parameter rd_addrw = 4,    //   
    parameter wr_addrw = 5,    //   
    parameter filename = "",   //
    parameter rd_port = "sync", //"sync","async"
    parameter fpga_type = "ultrascale"  //virtex, ultrascale

) (
    input wire clk,
    input wire [wr_addrw-1:0] wr_addr,
    input wire [wr_dataw-1:0] wr_data,
    input wire we,
    input wire [rd_addrw-1:0] rd_addr,
    output wire [rd_dataw-1:0] rd_data
);
    localparam integer cs_w = rd_dataw / wr_dataw;
    integer j,k;
    genvar i;
    wire [cs_w-1:0] write_enable;
    reg [rd_dataw-1:0] meminit [2**rd_addrw-1:0];
    //Memory array = "{auto | block | distributed | pipe_distributed | block_power1 | block_power2}"
    (* ram_style = "block" *) reg [wr_dataw-1:0] mem [cs_w-1:0][2**rd_addrw-1:0];
	 
    initial begin
        //      
        if (filename!="") begin
          $readmemb(filename, meminit);
          for (j = 0; j < cs_w; j = j+1) 
              for (k = 0; k < 2**rd_addrw; k = k+1) begin
                mem[j][k] = meminit[k][j*wr_dataw +: wr_dataw];
              end
        end
    end
	 //
    generate
        if (rd_port=="sync") begin //BlockRAM or UltraRAM
            for (i=0;i<cs_w;i=i+1) begin : mem_gen_sync  
                if (wr_addrw > rd_addrw) 
                  assign write_enable[i] = (wr_addr[wr_addrw-1:rd_addrw]==i);
                else
                  assign write_enable[i] = 1'b1;
                //Virtex 6 BRAM
                if (fpga_type=="virtex") begin  
                  wire we_i;
                  wire [rd_addrw-1:0] wr_addr_i;
                  reg [wr_dataw-1:0] rd_data_i;
                  assign we_i = write_enable[i] & we; 
                  assign wr_addr_i = wr_addr[rd_addrw-1:0];
                  always @(posedge clk) begin
                      if (we_i) begin
                              mem[i][wr_addr_i] <= wr_data;
                      end
                      rd_data_i = mem[i][rd_addr];
                  end
                  assign rd_data[i*wr_dataw+:wr_dataw] = rd_data_i;
                end
                //Ultrascale+ BRAM
                if (fpga_type=="ultrascale") begin  
                  xilinx_ultrascale_byte_enable_ram #(.addr_w(rd_addrw), .data_w(wr_dataw), .preload_file(filename), .idx(i)) ucmdram_block (
                  // Outputs
                  .data_out_a   (),
                  .data_out_b   (rd_data[i*wr_dataw+:wr_dataw]),
                  // Inputs
                  .clk          (clk),
                  .addr_a       (wr_addr[rd_addrw-1:0]),
                  .en_a         (1'b1),
                  .be_a         ({(wr_dataw/8){write_enable[i] & we}}),
                  .data_in_a    (wr_data),
                  .addr_b       (rd_addr),
                  .en_b         (1'b1),
                  .be_b         ({(wr_dataw/8){1'b0}}),
                  .data_in_b    (0));
                end
            end
        end else begin //LUTRAM
            for (i=0;i<cs_w;i=i+1) begin : mem_gen_async  
                wire we_i;
                wire [rd_addrw-1:0] wr_addr_i;
                if (wr_addrw > rd_addrw) 
                        assign write_enable[i] = (wr_addr[wr_addrw-1:rd_addrw]==i);
                else
                        assign write_enable[i] = 1'b1;
                assign we_i = write_enable[i] & we; 
                assign wr_addr_i = wr_addr[rd_addrw-1:0];
                always @(posedge clk) begin
                    if (we_i) begin
                            mem[i][wr_addr_i] <= wr_data;
                    end
                end
                assign rd_data[i*wr_dataw+:wr_dataw] = mem[i][rd_addr];
            end
        
        end
    endgenerate

endmodule

//Объявление модуля блочной памятизависит от архитектуры ПЛИС
module xilinx_ultrascale_byte_enable_ram 
    #(
        parameter data_w = 32,
        parameter addr_w = 12,
        parameter idx = 0,
        parameter preload_file = ""
        )
        (
        input wire clk,
        //port a
        input wire[addr_w-1:0] addr_a,
        input wire en_a,
        input wire[data_w/8-1:0] be_a,
        input wire[data_w-1:0] data_in_a,
        output reg[data_w-1:0] data_out_a,
        //port b
        input wire[addr_w-1:0] addr_b,
        input wire en_b,
        input wire[data_w/8-1:0] be_b,
        input wire[data_w-1:0] data_in_b,
        output reg[data_w-1:0] data_out_b
        );
    localparam lines = 2**addr_w;
    //Memory array = "{auto | block | distributed | pipe_distributed | block_power1 | block_power2}"
    (* ram_style = "block" *) reg [data_w-1:0] ram [lines-1:0];
    reg [(idx+1)*data_w-1:0] init_file [lines-1:0];
    integer j,k;
    initial
    begin: init_memory
        if(preload_file!="") begin
          $readmemb(preload_file,init_file,0,lines-1);
          `ifdef debug_ucmd
            $display("MEMORY BLOCK #%d\n", idx);
          `endif
          for(j = 0; j < lines; j = j+1) begin
            ram[j] = init_file[j][idx*data_w+:data_w]; 
            `ifdef debug_ucmd
              $display("mem_block_%d[%d]%b",idx,j,ram[j]);
            `endif
          end
        end else begin
          for(j = 0; j < lines; j = j+1) 
            ram[j] = {(data_w){1'b0}};
        end
        data_out_b = 0;
        data_out_a = 0;
    end

    generate
    genvar i;
    for (i=0; i < data_w/8; i=i+1) begin
        always @(posedge clk) begin
            if (en_a) begin
                if (be_a[i]) begin
                    ram[addr_a][8*i+:8] <= data_in_a[8*i+:8];
                    data_out_a[8*i+:8] <= data_in_a[8*i+:8];
                end else begin
                    data_out_a[8*i+:8] <= ram[addr_a][8*i+:8];
                end
            end
        end
    end
    
    for (i=0; i < data_w/8; i=i+1) begin
        always @(posedge clk) begin
            if (en_b) begin
                if (be_b[i]) begin
                    ram[addr_b][8*i+:8] <= data_in_b[8*i+:8];
                    data_out_b[8*i+:8] <= data_in_b[8*i+:8];
                end else begin
                    data_out_b[8*i+:8] <= ram[addr_b][8*i+:8];
                end
            end
        end
    end
    endgenerate
endmodule

// Управляющая часть автомата на цепях ускоренного переноса CARRY4
module carry4_chain #(parameter data_w = 32) (
    input wire [data_w-1:0] data_in,
    input wire carry_in,
    output wire result
  );
  
    localparam extended_data_w = ((data_w + 3) / 4) * 4; //
    wire [extended_data_w-1:0] extended_data_in;
    wire [extended_data_w-1:0] carry4_cout; //
    assign extended_data_in = {data_in,{(extended_data_w - data_w){1'b1}}};
  
    genvar i;
    generate
      CARRY4 u_carry4_0 (
          .S(extended_data_in[3:0]),
          .DI(4'b0),
          .CYINIT(carry_in),
          .CO(carry4_cout[0*4+:4]),
          .O()
      );
      for (i = 1; i < extended_data_w/4; i = i + 1) begin: carry4_i
        CARRY4 u_carry4_i (
          .S(extended_data_in[4*i+3:4*i]),
          .DI(4'b0),
          .CI(carry4_cout[i*4-1]),
          .CO(carry4_cout[i*4+:4]),
          .O()
        );
      end
    endgenerate
  
    assign result = carry4_cout[extended_data_w-1];
   
endmodule

module bitwise_logic_x8_with_carry4 #(parameter data_w = 32) (
  input wire [data_w-1:0] mask,
  input wire [data_w-1:0] fbs,
  input wire [data_w-1:0] fb,
  input wire en,
  output wire result
);
  localparam extended_data_w = ((data_w + 7) / 8) * 8; // Расширенная длина, кратная 2
  wire [extended_data_w-1:0] f;
  wire [(extended_data_w/2)-1:0] f_ext;
  
  // Вычисление f[i] для каждого бита
  assign f = {{~mask | ~(fb ^ fbs)},{(extended_data_w - data_w){1'b1}}};
  // Вычисление f2[i]
  genvar j;
  generate
    for (j = 0; j < extended_data_w/2; j = j + 1) begin: f_inst
      assign f_ext[j] = f[2*j] & f[2*j+1];
    end
  endgenerate
  // Каскадное подключение блоков CARRY4
  carry4_chain #(extended_data_w/2) u_carry4_chain_hello (.data_in(f_ext), .carry_in(en), .result(result));

endmodule

module ucmd_carry4 #(parameter ucmd_g = 2, parameter ucmd_adr = 32, parameter ucmd_fbs = 32) (
  input wire [ucmd_g*(2*ucmd_fbs+ucmd_adr+1)+ucmd_adr-1:0] ucmd,
  input wire [ucmd_fbs-1:0] fb,
  output wire [ucmd_adr-1:0] result_address
);

  localparam extended_ucmd_term_en_width = ((ucmd_g + 11) / 12) * 12;
  localparam term_w = 2*ucmd_fbs+ucmd_adr+1;
  genvar i,j,k,m,n;
 
  wire [extended_ucmd_term_en_width-1:0] extended_ucmd_term_en;
  wire [ucmd_adr-1:0] branch_adr[ucmd_g-1:0];
  wire [ucmd_fbs-1:0] fbsi_mask[ucmd_g-1:0];
  wire [ucmd_fbs-1:0] fbsi_value[ucmd_g-1:0];
  wire [ucmd_g-1:0] 	 ucmd_term_en;
  wire [ucmd_adr-1:0] default_adr;
  wire [ucmd_g-1:0]   ucmd_adr_mask;

  // 
  generate
    for (i = 0; i < ucmd_g; i = i + 1) begin: ucmd_gen
		assign ucmd_term_en[i] 	= ucmd[i*term_w];
		assign fbsi_value[i] 	= ucmd[i*term_w+1 			    +: ucmd_fbs];
		assign fbsi_mask[i] 	= ucmd[i*term_w+1+ucmd_fbs 	    +: ucmd_fbs];
		assign branch_adr[i] 	= ucmd[i*term_w+1+2*ucmd_fbs    +: ucmd_adr];
    end
  endgenerate
  assign default_adr = ucmd[ucmd_g*term_w +: ucmd_adr];
    
  //Обработка каждой группы
  generate
    for (k = 0; k < ucmd_g; k = k + 1) begin: adr_mask_gen
		  bitwise_logic_x8_with_carry4 #(.data_w(ucmd_fbs)) u_blwc (
			.mask(fbsi_mask[k]), .fbs(fbsi_value[k]), .fb(fb), .en(ucmd_term_en[k]), .result(ucmd_adr_mask[k]));
    end
  endgenerate

  //Расширение ucmd_adr_mask до размера, кратного 12
  assign extended_ucmd_term_en = {{(extended_ucmd_term_en_width - ucmd_g){1'b0}}, ucmd_adr_mask};
  
  //Обработка адресов с учетом ucmd_adr_mask
  wire [extended_ucmd_term_en_width-1:0] adr_enabled [ucmd_adr:0]; //Including inverted ucmd_adr_mask 
  generate
    for (i = 0; i < ucmd_adr; i = i + 1) begin: adr_en_gen_i
		for (j = 0; j < extended_ucmd_term_en_width; j = j + 1) begin: adr_en_gen_j
			if (j<ucmd_g) begin
				assign adr_enabled[i][j] = branch_adr[j][i] & extended_ucmd_term_en[j];
			end else begin
				assign adr_enabled[i][j] = 1'b0;
			end
      end
    end
	 //@default  
	 for (j = 0; j < extended_ucmd_term_en_width; j = j + 1) begin: edr_en_default_gen
		if (j<ucmd_g) begin
			assign adr_enabled[ucmd_adr][j] = extended_ucmd_term_en[j];
		end else begin
			assign adr_enabled[ucmd_adr][j] = 1'b0;
		end
	 end
  endgenerate

  // Вычисление adr_enabled3  с двумя вложенными циклами
  localparam extended_ucmd_term_en3_width = (extended_ucmd_term_en_width + 2) / 3; // Размер adr_enabled3 для каждого k
  wire [extended_ucmd_term_en3_width-1:0] adr_enabled3 [ucmd_adr:0];
  generate
    for (i = 0; i <= ucmd_adr; i = i + 1) begin: adr_en3_geni
		for (j = 0; j < extended_ucmd_term_en3_width; j = j + 1) begin: adr_en3_geni
        assign adr_enabled3[i][j] = ~(adr_enabled[i][3*j] | adr_enabled[i][3*j+1] | adr_enabled[i][3*j+2]);
      end
    end
  endgenerate

  //Обработка adr_enabled3 с использованием CARRY4
  wire [ucmd_adr:0] result_address_temp;
  wire [extended_ucmd_term_en3_width/4-1:0] carry4_cout [ucmd_adr:0]; //carry4_cout массив

  generate
    for (n = 0; n <= ucmd_adr; n = n+1) begin: carry4_chain_gen
		carry4_chain #(extended_ucmd_term_en3_width) u_carry4_chain_hello ( // Используем carry4_chain
        .data_in(adr_enabled3[n]),
		.carry_in(1'b1),
        .result(result_address_temp[n])
      );
    end
  endgenerate

  //Обработка результатa
  assign result_address[ucmd_adr-1:0] = (result_address_temp[ucmd_adr]) ? default_adr : ~result_address_temp[ucmd_adr-1:0];

endmodule

`endif

//Модуль верхнего уровня
module top_ucmd_fsm_hello #(    
    parameter ucmd_g                = 1, 
    parameter ucmd_fbs              = 9,    
    parameter ucmd_adr              = 5,
    parameter ucmd_c                = 11,    
    parameter cmd_c                 = 1,
    parameter ucmdRAM_data_w        = 32,
    parameter ucmdRAM_adr_w         = 6,
    parameter ucmdARAM_data_w       = 5,
    parameter ucmdARAM_adr_w        = 1,
    parameter ucmd_ram_type         = "sync",  //sync, async
    parameter control_type          = "carry4", //carry4, lut,
    parameter fpga_type             = "ultrascale"  //virtex, ultrascale
    )(    
    //COMMON SIGNALS
    input  wire                 rst,
    input  wire                 clk,    
    output wire [255:0]         debug,
    
	//COMMAND run
	input wire rvalid,

	//COMMAND SIGNALS
	input wire cmd0,

	//FEEDBACK SIGNALS
	input wire wready,
	input wire getchar7,
	input wire getchar6,
	input wire getchar5,
	input wire getchar4,
	input wire getchar3,
	input wire getchar2,
	input wire getchar1,
	input wire getchar0,

	//MICROCOMMAND SIGNALS
	output wire wvalid,
	output wire rready,
	output wire putchar7,
	output wire putchar6,
	output wire putchar5,
	output wire putchar4,
	output wire putchar3,
	output wire putchar2,
	output wire putchar1,
	output wire putchar0,
	output wire echo,


  //ucmdRAM signals 
  input  wire [ucmdRAM_data_w-1:0]       ucmdRAM_data,
  input  wire [ucmdRAM_adr_w-1:0]        ucmdRAM_adr,
  input  wire                            ucmdRAM_we,
  //ucmdARAM signals 
  input  wire [ucmdARAM_data_w-1:0]      ucmdARAM_data,
  input  wire [ucmdARAM_adr_w-1:0]       ucmdARAM_adr,
  input  wire                            ucmdARAM_we,
  output wire                            busy
);

    wire [cmd_c-1:0] cmd;
    wire run;    
    wire [ucmd_fbs-1:0] fbs;
    wire [ucmd_c-1:0] ucmd;
    wire [ucmd_adr-1:0] ucmd_state;
    // Пример формирования отладочного вектора:    
    assign debug[ucmd_fbs+ucmd_adr:0] = {fbs, ucmd_state, run};
    // Остальные биты debug можно обнулить:    
    assign debug[255:ucmd_fbs+ucmd_adr+1] = 0;
    //Сигналы
    `ifndef chipscope
	assign cmd = {
		cmd0};
	assign run = rvalid;
	assign fbs = {
		wready,
		getchar7,
		getchar6,
		getchar5,
		getchar4,
		getchar3,
		getchar2,
		getchar1,
		getchar0};
    `endif
	assign wvalid = ucmd[10];
	assign rready = ucmd[9];
	assign putchar7 = ucmd[8];
	assign putchar6 = ucmd[7];
	assign putchar5 = ucmd[6];
	assign putchar4 = ucmd[5];
	assign putchar3 = ucmd[4];
	assign putchar2 = ucmd[3];
	assign putchar1 = ucmd[2];
	assign putchar0 = ucmd[1];
	assign echo = ucmd[0];



    // Микропрограммный автомат
    ucmd_fsm #(
        .ucmd_g(ucmd_g),        
        .ucmd_fbs(ucmd_fbs),
        .ucmd_adr(ucmd_adr),        
        .ucmd_c(ucmd_c),
        .cmd_c(cmd_c),
        .ucmdRAM_data_w(ucmdRAM_data_w),
        .ucmdRAM_adr_w(ucmdRAM_adr_w),
        .ucmdARAM_data_w(ucmdARAM_data_w),
        .ucmdARAM_adr_w(ucmdARAM_adr_w),
        .ucmd_ram_type(ucmd_ram_type),
        .mcmem_file("uart_hello_world.mcmem"),
        .adrmem_file("uart_hello_world.adrmem"),
        .control_type(control_type),
        .fpga_type(fpga_type)
    ) 
    Inst_ucmd_fsm_hello (
        .rst(rst),
        .clk(clk),        
        .cmd(cmd),
        .run(run),        
        .fbs(fbs),
        .ucmd(ucmd),   
        .busy(busy),     
        .ucmd_state(ucmd_state),
        //ucmdRAM signals 
        .ucmdRAM_data(ucmdRAM_data),
        .ucmdRAM_adr(ucmdRAM_adr),
        .ucmdRAM_we(ucmdRAM_we),
        //ucmdARAM signals 
        .ucmdARAM_data(ucmdARAM_data),
        .ucmdARAM_adr(ucmdARAM_adr),
        .ucmdARAM_we(ucmdARAM_we)    
    );


// Chipscope instantation templates

`ifdef chipscope
    wire [35:0] icon_control0;
    wire [35:0] icon_control1;
    wire [255:0] ila_trig0;
    wire [11-1:0] vio_port;
    icon icon_inst (
        .CONTROL0(icon_control0),
        .CONTROL1(icon_control1) 
    );
    ila ila_inst (
        .CONTROL(icon_control0), 
        .CLK(clk), 			
        .TRIG0(ila_trig0) 		
    );
    vio vio_inst (
        .CONTROL(icon_control1), 
        .CLK(clk), 			
        .SYNC_OUT(vio_port) 		
    );
	assign ila_trig0 = {    
        busy,ucmd_state[ucmd_adr-1:0],ucmd[ucmd_c-1:0],cmd[cmd_c-1:0],run,fbs[ucmd_fbs-1:0],
        {(256-ucmd_c-cmd_c-ucmd_fbs-ucmd_adr-2){1'b0}}
    };
	assign run = vio_port[0];
	assign cmd = vio_port[9:1];
	assign fbs = vio_port[1+9:9+1];

`endif


endmodule

// ILA Chip Scope проекты (шаблон *.cdc)
/*
#ChipScope Core Generator Project File Version 3.0
#Sat Jun 16 18:20:51 RTZ 2 (зима) 2018
SignalExport.bus<0000>.channelList=0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255
SignalExport.bus<0000>.name=trig0
SignalExport.bus<0000>.offset=0.0
SignalExport.bus<0000>.precision=0
SignalExport.bus<0000>.radix=Bin
SignalExport.bus<0000>.scaleFactor=1.0
SignalExport.clockChannel=CLK
SignalExport.dataEqualsTrigger=true
SignalExport.triggerChannel<0000><0255>=busy
SignalExport.triggerChannel<0000><0254>=ucmd_state[4]
SignalExport.triggerChannel<0000><0253>=ucmd_state[3]
SignalExport.triggerChannel<0000><0252>=ucmd_state[2]
SignalExport.triggerChannel<0000><0251>=ucmd_state[1]
SignalExport.triggerChannel<0000><0250>=ucmd_state[0]
SignalExport.triggerChannel<0000><0249>=wvalid
SignalExport.triggerChannel<0000><0248>=rready
SignalExport.triggerChannel<0000><0247>=putchar7
SignalExport.triggerChannel<0000><0246>=putchar6
SignalExport.triggerChannel<0000><0245>=putchar5
SignalExport.triggerChannel<0000><0244>=putchar4
SignalExport.triggerChannel<0000><0243>=putchar3
SignalExport.triggerChannel<0000><0242>=putchar2
SignalExport.triggerChannel<0000><0241>=putchar1
SignalExport.triggerChannel<0000><0240>=putchar0
SignalExport.triggerChannel<0000><0239>=echo
SignalExport.triggerChannel<0000><0238>=cmd0
SignalExport.triggerChannel<0000><0237>=rvalid
SignalExport.triggerChannel<0000><0236>=wready
SignalExport.triggerChannel<0000><0235>=getchar7
SignalExport.triggerChannel<0000><0234>=getchar6
SignalExport.triggerChannel<0000><0233>=getchar5
SignalExport.triggerChannel<0000><0232>=getchar4
SignalExport.triggerChannel<0000><0231>=getchar3
SignalExport.triggerChannel<0000><0230>=getchar2
SignalExport.triggerChannel<0000><0229>=getchar1
SignalExport.triggerChannel<0000><0228>=getchar0
SignalExport.triggerChannel<0000><0227>=TRIG00227
SignalExport.triggerChannel<0000><0226>=TRIG00226
SignalExport.triggerChannel<0000><0225>=TRIG00225
SignalExport.triggerChannel<0000><0224>=TRIG00224
SignalExport.triggerChannel<0000><0223>=TRIG00223
SignalExport.triggerChannel<0000><0222>=TRIG00222
SignalExport.triggerChannel<0000><0221>=TRIG00221
SignalExport.triggerChannel<0000><0220>=TRIG00220
SignalExport.triggerChannel<0000><0219>=TRIG00219
SignalExport.triggerChannel<0000><0218>=TRIG00218
SignalExport.triggerChannel<0000><0217>=TRIG00217
SignalExport.triggerChannel<0000><0216>=TRIG00216
SignalExport.triggerChannel<0000><0215>=TRIG00215
SignalExport.triggerChannel<0000><0214>=TRIG00214
SignalExport.triggerChannel<0000><0213>=TRIG00213
SignalExport.triggerChannel<0000><0212>=TRIG00212
SignalExport.triggerChannel<0000><0211>=TRIG00211
SignalExport.triggerChannel<0000><0210>=TRIG00210
SignalExport.triggerChannel<0000><0209>=TRIG00209
SignalExport.triggerChannel<0000><0208>=TRIG00208
SignalExport.triggerChannel<0000><0207>=TRIG00207
SignalExport.triggerChannel<0000><0206>=TRIG00206
SignalExport.triggerChannel<0000><0205>=TRIG00205
SignalExport.triggerChannel<0000><0204>=TRIG00204
SignalExport.triggerChannel<0000><0203>=TRIG00203
SignalExport.triggerChannel<0000><0202>=TRIG00202
SignalExport.triggerChannel<0000><0201>=TRIG00201
SignalExport.triggerChannel<0000><0200>=TRIG00200
SignalExport.triggerChannel<0000><0199>=TRIG00199
SignalExport.triggerChannel<0000><0198>=TRIG00198
SignalExport.triggerChannel<0000><0197>=TRIG00197
SignalExport.triggerChannel<0000><0196>=TRIG00196
SignalExport.triggerChannel<0000><0195>=TRIG00195
SignalExport.triggerChannel<0000><0194>=TRIG00194
SignalExport.triggerChannel<0000><0193>=TRIG00193
SignalExport.triggerChannel<0000><0192>=TRIG00192
SignalExport.triggerChannel<0000><0191>=TRIG00191
SignalExport.triggerChannel<0000><0190>=TRIG00190
SignalExport.triggerChannel<0000><0189>=TRIG00189
SignalExport.triggerChannel<0000><0188>=TRIG00188
SignalExport.triggerChannel<0000><0187>=TRIG00187
SignalExport.triggerChannel<0000><0186>=TRIG00186
SignalExport.triggerChannel<0000><0185>=TRIG00185
SignalExport.triggerChannel<0000><0184>=TRIG00184
SignalExport.triggerChannel<0000><0183>=TRIG00183
SignalExport.triggerChannel<0000><0182>=TRIG00182
SignalExport.triggerChannel<0000><0181>=TRIG00181
SignalExport.triggerChannel<0000><0180>=TRIG00180
SignalExport.triggerChannel<0000><0179>=TRIG00179
SignalExport.triggerChannel<0000><0178>=TRIG00178
SignalExport.triggerChannel<0000><0177>=TRIG00177
SignalExport.triggerChannel<0000><0176>=TRIG00176
SignalExport.triggerChannel<0000><0175>=TRIG00175
SignalExport.triggerChannel<0000><0174>=TRIG00174
SignalExport.triggerChannel<0000><0173>=TRIG00173
SignalExport.triggerChannel<0000><0172>=TRIG00172
SignalExport.triggerChannel<0000><0171>=TRIG00171
SignalExport.triggerChannel<0000><0170>=TRIG00170
SignalExport.triggerChannel<0000><0169>=TRIG00169
SignalExport.triggerChannel<0000><0168>=TRIG00168
SignalExport.triggerChannel<0000><0167>=TRIG00167
SignalExport.triggerChannel<0000><0166>=TRIG00166
SignalExport.triggerChannel<0000><0165>=TRIG00165
SignalExport.triggerChannel<0000><0164>=TRIG00164
SignalExport.triggerChannel<0000><0163>=TRIG00163
SignalExport.triggerChannel<0000><0162>=TRIG00162
SignalExport.triggerChannel<0000><0161>=TRIG00161
SignalExport.triggerChannel<0000><0160>=TRIG00160
SignalExport.triggerChannel<0000><0159>=TRIG00159
SignalExport.triggerChannel<0000><0158>=TRIG00158
SignalExport.triggerChannel<0000><0157>=TRIG00157
SignalExport.triggerChannel<0000><0156>=TRIG00156
SignalExport.triggerChannel<0000><0155>=TRIG00155
SignalExport.triggerChannel<0000><0154>=TRIG00154
SignalExport.triggerChannel<0000><0153>=TRIG00153
SignalExport.triggerChannel<0000><0152>=TRIG00152
SignalExport.triggerChannel<0000><0151>=TRIG00151
SignalExport.triggerChannel<0000><0150>=TRIG00150
SignalExport.triggerChannel<0000><0149>=TRIG00149
SignalExport.triggerChannel<0000><0148>=TRIG00148
SignalExport.triggerChannel<0000><0147>=TRIG00147
SignalExport.triggerChannel<0000><0146>=TRIG00146
SignalExport.triggerChannel<0000><0145>=TRIG00145
SignalExport.triggerChannel<0000><0144>=TRIG00144
SignalExport.triggerChannel<0000><0143>=TRIG00143
SignalExport.triggerChannel<0000><0142>=TRIG00142
SignalExport.triggerChannel<0000><0141>=TRIG00141
SignalExport.triggerChannel<0000><0140>=TRIG00140
SignalExport.triggerChannel<0000><0139>=TRIG00139
SignalExport.triggerChannel<0000><0138>=TRIG00138
SignalExport.triggerChannel<0000><0137>=TRIG00137
SignalExport.triggerChannel<0000><0136>=TRIG00136
SignalExport.triggerChannel<0000><0135>=TRIG00135
SignalExport.triggerChannel<0000><0134>=TRIG00134
SignalExport.triggerChannel<0000><0133>=TRIG00133
SignalExport.triggerChannel<0000><0132>=TRIG00132
SignalExport.triggerChannel<0000><0131>=TRIG00131
SignalExport.triggerChannel<0000><0130>=TRIG00130
SignalExport.triggerChannel<0000><0129>=TRIG00129
SignalExport.triggerChannel<0000><0128>=TRIG00128
SignalExport.triggerChannel<0000><0127>=TRIG00127
SignalExport.triggerChannel<0000><0126>=TRIG00126
SignalExport.triggerChannel<0000><0125>=TRIG00125
SignalExport.triggerChannel<0000><0124>=TRIG00124
SignalExport.triggerChannel<0000><0123>=TRIG00123
SignalExport.triggerChannel<0000><0122>=TRIG00122
SignalExport.triggerChannel<0000><0121>=TRIG00121
SignalExport.triggerChannel<0000><0120>=TRIG00120
SignalExport.triggerChannel<0000><0119>=TRIG00119
SignalExport.triggerChannel<0000><0118>=TRIG00118
SignalExport.triggerChannel<0000><0117>=TRIG00117
SignalExport.triggerChannel<0000><0116>=TRIG00116
SignalExport.triggerChannel<0000><0115>=TRIG00115
SignalExport.triggerChannel<0000><0114>=TRIG00114
SignalExport.triggerChannel<0000><0113>=TRIG00113
SignalExport.triggerChannel<0000><0112>=TRIG00112
SignalExport.triggerChannel<0000><0111>=TRIG00111
SignalExport.triggerChannel<0000><0110>=TRIG00110
SignalExport.triggerChannel<0000><0109>=TRIG00109
SignalExport.triggerChannel<0000><0108>=TRIG00108
SignalExport.triggerChannel<0000><0107>=TRIG00107
SignalExport.triggerChannel<0000><0106>=TRIG00106
SignalExport.triggerChannel<0000><0105>=TRIG00105
SignalExport.triggerChannel<0000><0104>=TRIG00104
SignalExport.triggerChannel<0000><0103>=TRIG00103
SignalExport.triggerChannel<0000><0102>=TRIG00102
SignalExport.triggerChannel<0000><0101>=TRIG00101
SignalExport.triggerChannel<0000><0100>=TRIG00100
SignalExport.triggerChannel<0000><0099>=TRIG00099
SignalExport.triggerChannel<0000><0098>=TRIG00098
SignalExport.triggerChannel<0000><0097>=TRIG00097
SignalExport.triggerChannel<0000><0096>=TRIG00096
SignalExport.triggerChannel<0000><0095>=TRIG00095
SignalExport.triggerChannel<0000><0094>=TRIG00094
SignalExport.triggerChannel<0000><0093>=TRIG00093
SignalExport.triggerChannel<0000><0092>=TRIG00092
SignalExport.triggerChannel<0000><0091>=TRIG00091
SignalExport.triggerChannel<0000><0090>=TRIG00090
SignalExport.triggerChannel<0000><0089>=TRIG00089
SignalExport.triggerChannel<0000><0088>=TRIG00088
SignalExport.triggerChannel<0000><0087>=TRIG00087
SignalExport.triggerChannel<0000><0086>=TRIG00086
SignalExport.triggerChannel<0000><0085>=TRIG00085
SignalExport.triggerChannel<0000><0084>=TRIG00084
SignalExport.triggerChannel<0000><0083>=TRIG00083
SignalExport.triggerChannel<0000><0082>=TRIG00082
SignalExport.triggerChannel<0000><0081>=TRIG00081
SignalExport.triggerChannel<0000><0080>=TRIG00080
SignalExport.triggerChannel<0000><0079>=TRIG00079
SignalExport.triggerChannel<0000><0078>=TRIG00078
SignalExport.triggerChannel<0000><0077>=TRIG00077
SignalExport.triggerChannel<0000><0076>=TRIG00076
SignalExport.triggerChannel<0000><0075>=TRIG00075
SignalExport.triggerChannel<0000><0074>=TRIG00074
SignalExport.triggerChannel<0000><0073>=TRIG00073
SignalExport.triggerChannel<0000><0072>=TRIG00072
SignalExport.triggerChannel<0000><0071>=TRIG00071
SignalExport.triggerChannel<0000><0070>=TRIG00070
SignalExport.triggerChannel<0000><0069>=TRIG00069
SignalExport.triggerChannel<0000><0068>=TRIG00068
SignalExport.triggerChannel<0000><0067>=TRIG00067
SignalExport.triggerChannel<0000><0066>=TRIG00066
SignalExport.triggerChannel<0000><0065>=TRIG00065
SignalExport.triggerChannel<0000><0064>=TRIG00064
SignalExport.triggerChannel<0000><0063>=TRIG00063
SignalExport.triggerChannel<0000><0062>=TRIG00062
SignalExport.triggerChannel<0000><0061>=TRIG00061
SignalExport.triggerChannel<0000><0060>=TRIG00060
SignalExport.triggerChannel<0000><0059>=TRIG00059
SignalExport.triggerChannel<0000><0058>=TRIG00058
SignalExport.triggerChannel<0000><0057>=TRIG00057
SignalExport.triggerChannel<0000><0056>=TRIG00056
SignalExport.triggerChannel<0000><0055>=TRIG00055
SignalExport.triggerChannel<0000><0054>=TRIG00054
SignalExport.triggerChannel<0000><0053>=TRIG00053
SignalExport.triggerChannel<0000><0052>=TRIG00052
SignalExport.triggerChannel<0000><0051>=TRIG00051
SignalExport.triggerChannel<0000><0050>=TRIG00050
SignalExport.triggerChannel<0000><0049>=TRIG00049
SignalExport.triggerChannel<0000><0048>=TRIG00048
SignalExport.triggerChannel<0000><0047>=TRIG00047
SignalExport.triggerChannel<0000><0046>=TRIG00046
SignalExport.triggerChannel<0000><0045>=TRIG00045
SignalExport.triggerChannel<0000><0044>=TRIG00044
SignalExport.triggerChannel<0000><0043>=TRIG00043
SignalExport.triggerChannel<0000><0042>=TRIG00042
SignalExport.triggerChannel<0000><0041>=TRIG00041
SignalExport.triggerChannel<0000><0040>=TRIG00040
SignalExport.triggerChannel<0000><0039>=TRIG00039
SignalExport.triggerChannel<0000><0038>=TRIG00038
SignalExport.triggerChannel<0000><0037>=TRIG00037
SignalExport.triggerChannel<0000><0036>=TRIG00036
SignalExport.triggerChannel<0000><0035>=TRIG00035
SignalExport.triggerChannel<0000><0034>=TRIG00034
SignalExport.triggerChannel<0000><0033>=TRIG00033
SignalExport.triggerChannel<0000><0032>=TRIG00032
SignalExport.triggerChannel<0000><0031>=TRIG00031
SignalExport.triggerChannel<0000><0030>=TRIG00030
SignalExport.triggerChannel<0000><0029>=TRIG00029
SignalExport.triggerChannel<0000><0028>=TRIG00028
SignalExport.triggerChannel<0000><0027>=TRIG00027
SignalExport.triggerChannel<0000><0026>=TRIG00026
SignalExport.triggerChannel<0000><0025>=TRIG00025
SignalExport.triggerChannel<0000><0024>=TRIG00024
SignalExport.triggerChannel<0000><0023>=TRIG00023
SignalExport.triggerChannel<0000><0022>=TRIG00022
SignalExport.triggerChannel<0000><0021>=TRIG00021
SignalExport.triggerChannel<0000><0020>=TRIG00020
SignalExport.triggerChannel<0000><0019>=TRIG00019
SignalExport.triggerChannel<0000><0018>=TRIG00018
SignalExport.triggerChannel<0000><0017>=TRIG00017
SignalExport.triggerChannel<0000><0016>=TRIG00016
SignalExport.triggerChannel<0000><0015>=TRIG00015
SignalExport.triggerChannel<0000><0014>=TRIG00014
SignalExport.triggerChannel<0000><0013>=TRIG00013
SignalExport.triggerChannel<0000><0012>=TRIG00012
SignalExport.triggerChannel<0000><0011>=TRIG00011
SignalExport.triggerChannel<0000><0010>=TRIG00010
SignalExport.triggerChannel<0000><0009>=TRIG00009
SignalExport.triggerChannel<0000><0008>=TRIG00008
SignalExport.triggerChannel<0000><0007>=TRIG00007
SignalExport.triggerChannel<0000><0006>=TRIG00006
SignalExport.triggerChannel<0000><0005>=TRIG00005
SignalExport.triggerChannel<0000><0004>=TRIG00004
SignalExport.triggerChannel<0000><0003>=TRIG00003
SignalExport.triggerChannel<0000><0002>=TRIG00002
SignalExport.triggerChannel<0000><0001>=TRIG00001
SignalExport.triggerChannel<0000><0000>=TRIG00000
SignalExport.triggerPort<0000>.name=trig0
SignalExport.triggerPortCount=1
SignalExport.triggerPortIsData<0000>=true
SignalExport.triggerPortWidth<0000>=256
SignalExport.type=ila
*/

// VIO Chip Scope проекты (шаблон *.cdc)
/*
#ChipScope Core Generator Project File Version 3.0
#Mon Dec 30 23:04:45 MSK 2024
SignalExport.asyncInputWidth=0
SignalExport.asyncOutputWidth=0
SignalExport.clockChannel=CLK
SignalExport.syncInputWidth=0
SignalExport.syncOutput<0010>=wready
SignalExport.syncOutput<0009>=getchar7
SignalExport.syncOutput<0008>=getchar6
SignalExport.syncOutput<0007>=getchar5
SignalExport.syncOutput<0006>=getchar4
SignalExport.syncOutput<0005>=getchar3
SignalExport.syncOutput<0004>=getchar2
SignalExport.syncOutput<0003>=getchar1
SignalExport.syncOutput<0002>=getchar0
SignalExport.syncOutput<0001>=cmd0
SignalExport.syncOutput<0000>=rvalid
SignalExport.syncOutputWidth=11
SignalExport.type=vio
*/
