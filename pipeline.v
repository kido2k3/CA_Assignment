//b1, không có branch và các hazard
//chỉ là kiến trúc cơ bản chỉ có lệnh R
//chưa làm theo yêu cầu cơ bản của đ�? thầy

module system(
    input SYS_clk,
    input SYS_reset,
    input SYS_load,
    input [7:0] SYS_pc_val,
    input [7 :0] SYS_output_sel,
    output[26:0] SYS_leds
);
    //FETCH stage
    reg [31:0] PC;
    always @(negedge SYS_clk)
    begin
        PC <= PC + 4;
    end

    wire [31:0] F_instruction;
    IMEM imem (.IMEM_PC(PC), .IMEM_instruction(F_instruction)); //đ�?c lấy lệnh ra

    //DECODE stage
    wire        D_instruction;
    wire [10:0] D_control_signal;
    wire [31:0] D_REG_data_out1;
    wire [31:0] D_REG_data_out2;
    wire [4:0]  D_write_register;
    wire [31:0] D_Out_SignedExtended;
    decode_stage decode (//INPUT
                         .SYS_clk               (SYS_clk),
                         .SYS_reset             (SYS_reset),
                         .F_instruction         (F_instruction),
                         .WB_RegWrite_signal    (WB_RegWrite_signal),
                         .WB_write_register     (WB_write_register),
                         .WB_write_data         (WB_write_data),
                         //OUTPUT
                         .D_instruction         (D_instruction),
                         .D_control_signal      (D_control_signal),
                         .D_REG_data_out1       (D_REG_data_out1),
                         .D_REG_data_out2       (D_REG_data_out2),
                         .D_write_register      (D_write_register),
                         .D_Out_SignedExtended  (D_Out_SignedExtended)
                        );

    //EXECUTION stage
    wire [31:0] EX_instruction;
    wire [4:0]  EX_write_register;
    wire [10:0] EX_control_signal;
    wire [31:0] EX_ALUresult;
    wire [31:0] EX_operand2;
    execution_stage EX(//INPUT
                        .SYS_clk                (SYS_clk),
                        .SYS_reset              (SYS_reset),
                        .D_instruction          (D_instruction),
                        .D_control_signal       (D_control_signal),
                        .D_REG_data_out1        (D_REG_data_out1),
                        .D_REG_data_out2        (D_REG_data_out2),
                        .D_write_register       (D_write_register),
                        .D_Out_SignedExtended   (D_Out_SignedExtended),
                        //OUTPUT
                        .EX_instruction         (EX_instruction), 
                        .EX_control_signal      (EX_control_signal),
                        .EX_ALUresult           (EX_ALUresult),
                        .EX_operand2            (EX_operand2),
                        .EX_write_register      (EX_write_register)
                      );

    //MEMORY stage
    wire [31:0] MEM_control_signal;
    wire [31:0] MEM_ALUresult;
    wire [31:0] MEM_read_data;
    wire [4:0]  MEM_write_register;
    memory_stage MEM  (//INPUT
                        .SYS_clk            (SYS_clk),
                        .SYS_reset          (SYS_reset),
                        .EX_instruction     (EX_instruction),
                        .EX_write_register  (EX_write_register),
                        .EX_control_signal  (EX_control_signal),
                        .EX_ALUresult       (EX_ALUresult),
                        .EX_operand2        (EX_operand2),
                        //OUTPUT
                        .MEM_control_signal (MEM_control_signal),
                        .MEM_ALUresult      (MEM_ALUresult),
                        .MEM_read_data      (MEM_read_data),
                        .MEM_write_register (MEM_write_register)
                      );

    //Write Back stage
    wire        WB_RegWrite_signal;
    wire [4:0]  WB_write_register;
    WB_stage WB (//INPUT
                .SYS_clk            (SYS_clk),
                .SYS_reset          (SYS_reset),
                .MEM_control_signal (MEM_control_signal),
                .MEM_read_data      (MEM_read_data),
                .MEM_ALUresult      (MEM_ALUresult),
                .MEM_write_register (MEM_write_register),
                //OUTPUT
                .WB_write_data      (WB_write_data),
                .WB_RegWrite_signal (WB_RegWrite_signal),
                .WB_write_register  (WB_write_register)
                );
endmodule


module decode_stage (
    input             SYS_clk,
    input             SYS_reset,
    input             F_instruction,
    input             WB_RegWrite_signal,
    input             WB_write_register,
    input             WB_write_data,  

    output reg [31:0] D_instruction,    //lưu giữ instruction để handle được hazard
    output     [10:0] D_control_signal, //cứ lưu giữ hết tất cả các tín hiệu control
    output     [31:0] D_REG_data_out1,
    output     [31:0] D_REG_data_out2,
    output     [4:0]  D_write_register,
    output     [31:0] D_Out_SignedExtended         
);
    always @(negedge SYS_clk)
    begin
        D_instruction <= F_instruction;
    end
    
    control crl1 (.opcode         (D_instruction[31:26]),//INPUT
                  .control_signal (D_control_signal)    //tín hiệu control output ra
                 );

    assign D_write_register  = (D_control_signal[0]) ? D_instruction[15:11]:D_instruction[20:16]; //nên write vào rd hay rt, tức là I hay R

    SignedExtended SE1 (D_instruction[15:0], D_Out_SignedExtended[31:0]);
    
    REG     Reg1 (//for WB stage
                 .clk             (SYS_clk),             //clock này chỉ để write ở WB
                 .REG_address_wr  (WB_write_register),   //địa chỉ để ghi vào, là rd trong R, rt trong I
                 .REG_write_1     (WB_RegWrite_signal), //tín hiê ucho phép ghi hay không
                 .REG_data_wb_in1 (WB_write_data),      //dữ liệu tính toán ra được sắp được ghi vào.
                 //INPUT
                 .REG_address1    (D_instruction[25:21]), //địa chỉ rs
                 .REG_address2    (D_instruction[20:16]), //địa chỉ rt
                 //OUTPUT
                 .REG_data_out1   (D_REG_data_out1), //giá trị rs đ�?c được để đưa vào tính toán
                 .REG_data_out2   (D_REG_data_out2) //giá trị rt đ�?c được để đưa vào tính toán
                 );
endmodule


module execution_stage (
    input             SYS_clk,
    input             SYS_reset,
    input      [31:0] D_instruction,
    input      [10:0] D_control_signal, //cứ lưu giữ hết tất cả các tín hiệu control
    input      [31:0] D_REG_data_out1,
    input      [31:0] D_REG_data_out2,
    input      [4:0]  D_write_register,
    input      [31:0] D_Out_SignedExtended,

    output reg [31:0] EX_instruction, 
    output reg [10:0] EX_control_signal,
    output     [31:0] EX_ALUresult,
    output reg [31:0] EX_operand2,
    output reg [4:0]  EX_write_register  //để sử dụng ở WB

);
    reg [31:0] EX_operand1;
    reg [31:0] EX_Out_SignedExtended;

    wire [3:0] alu_control;
    wire [31:0] ALUSRC;

    always @(negedge SYS_clk)
    begin
        EX_instruction        <= D_instruction;
        EX_control_signal     <= D_control_signal;
        EX_operand1              <= D_REG_data_out1;
        EX_operand2              <= D_REG_data_out2;
        EX_Out_SignedExtended <= D_Out_SignedExtended;
        EX_write_register     <= D_write_register;
    end

    ALU_control AC1 (.ALUop       (EX_control_signal[5:4]), //input
                     .funct       (EX_instruction   [5:0]), //input
                     .control_out (alu_control      [3:0]) //output
                    );
    assign ALUSRC[31:0] = (EX_control_signal[2])?
                          EX_Out_SignedExtended[31:0] : EX_operand2[31:0]; //quyết định ch�?n trư�?ng nhập vào ALU tùy theo R hay I
    ALU         alu1 (//INPUT
                      .control      (alu_control[3:0]),
                      .a            (EX_operand1[31:0]), //rs in
                      .b            (ALUSRC[31:0]),       //rt or imm
                      //OUTPUT
                      .result_out   (EX_ALUresult[31:0]),
                      .status_out   (status_out) //trạng thái của phép tín htrong alu
                     );
endmodule


module memory_stage (
    input             SYS_clk,
    input             SYS_reset,
    input      [31:0] EX_instruction, 
    input      [4:0]  EX_write_register,
    input      [10:0] EX_control_signal,
    input      [31:0] EX_ALUresult,
    input      [31:0] EX_operand2,

    output reg [31:0] MEM_control_signal,
    output reg [31:0] MEM_ALUresult,
    output     [31:0] MEM_read_data,
    output reg [4:0]  MEM_write_register
);
    reg [31:0] MEM_instruction;
    reg [31:0] MEM_write_data;

    always@(SYS_clk)
    begin
        MEM_instruction    <= EX_instruction;
        MEM_control_signal <= EX_control_signal;
        MEM_ALUresult      <= EX_ALUresult;
        MEM_write_data     <= EX_operand2;
        MEM_write_register <= EX_write_register;
    end

    assign MemRead_signal = MEM_control_signal[8];
    assign MemWrite_signal = MEM_control_signal[7];

    DMEM    d1( //INPUT
                .DMEM_address   (MEM_ALUresult), //alu and adrress
                .DMEM_data_in   (MEM_write_data), 
                .DMEM_mem_write (MemWrite_signal), //tín hiệu đi�?u khiển cho phép ghi
                .DMEM_mem_read  (MemRead_signal),  //tín hiệu đi�?u khiển cho phép đ�?c
                .clk            (SYS_clk), 
                //OUTPUT
                .DMEM_data_out  (MEM_read_data)
               );
endmodule

module WB_stage (
    input             SYS_clk,
    input             SYS_reset,
    input      [31:0] MEM_control_signal,
    input      [31:0] MEM_read_data,
    input      [31:0] MEM_ALUresult,
    input      [4:0]  MEM_write_register,

    output            WB_write_data,
    output            WB_RegWrite_signal,
    output reg [4:0]  WB_write_register
);
    reg [31:0] WB_control_signal;
    reg [31:0] WB_read_data;
    reg [31:0] WB_ALUresult;

    always @(SYS_clk)
    begin
        WB_control_signal <= MEM_control_signal;
        WB_read_data      <= MEM_read_data;
        WB_ALUresult      <= MEM_ALUresult;
        WB_write_register <= MEM_write_register;
    end

    assign WB_RegWrite_signal = WB_control_signal[1];
    assign WB_write_data =  WB_control_signal[6] ? WB_read_data : WB_ALUresult;
endmodule