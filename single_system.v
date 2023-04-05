`timescale 1ns / 1ps

// đây là file chính chứa cpu của hệ thống

module system(
    input SYS_clk,
    input SYS_reset,
    input SYS_load,
    input [7:0] SYS_pc_val,
    input [7 :0] SYS_output_sel,
    output[26:0] SYS_leds
);
    reg [31:0] PC;
    reg [7:0] EPC;

    wire [31:0] instruction;
    wire [4:0]RDst;
    wire [31:0] REG_data_out;
    wire [31:0] REG_data_out2;
    wire IsAddi;
    wire [31:0] Out_SignedExtended;
    wire [3:0] control_out;
    wire ex;
    wire [31:0] ALUSRC;
    wire [31:0] result_out;
    wire [7:0] status_out;
    wire [31:0] DMEM_data_out;
    wire [31:0] Mem2Reg;
    wire [7:0] Branch;
    wire [5:0] Ex4to6_out;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    
    wire [10:0] control_signal;
    assign jump_signal      = control_signal[10];
    assign branch_signal    = control_signal[9];
    assign MemRead_signal   = control_signal[8];
    assign MemWrite_signal  = control_signal[7];
    assign Mem2Reg_signal   = control_signal[6];
    assign ALUop_signal     = control_signal[5:4];
    assign exception_signal = control_signal[3];
    assign ALUsrc_signal    = control_signal[2];
    assign RegWrite_signal  = control_signal[1];
    assign RegDst_signal    = control_signal[0];

    IMEM        imem (.IMEM_PC(PC), .IMEM_instruction(instruction)); //đọc lấy lệnh ra

    REG         Reg1 (  .clk            (SYS_clk),      
                        .REG_address1   (instruction[25:21]), //địa chỉ rs
                        .REG_address2   (instruction[20:16]), //địa chỉ rt
                        .REG_address_wr (RDst),               //địa chỉ rd, hay là địa chỉ để ghi vào
                        .REG_write_1    (RegWrite_signal),    //tín hiê ucho phép ghi hay không
                        .REG_data_wb_in1(Mem2Reg),            //dữ liệu tính toán ra được sắp được ghi vào.
                        .REG_data_out1  (REG_data_out[31:0]), //giá trị rs đọc được để đưa vào tính toán
                        .REG_data_out2  (REG_data_out2[31:0]) //giá trị rt đọc được để đưa vào tính toán
                     );

    // control     crl1 ( .opcode          (instruction[31:26]),
    //                    .rd              (instruction[15:11]), 
    //                    .rt              (instruction[20:16]),
    //                    .control_signal  (control_signal), //tín hiệ output ra
    //                    .IsAddi          (IsAddi)
    //                    );
    control     crl1 (.opcode          (instruction[31:26]),
                      .control_signal  (control_signal), //tín hiệ output ra
                     );

    //OLD
    // ALU_control AC1 (.ALUop       (control_signal[5:4]), //input
    //                  .func_in     (instruction[5:0]),    //input
    //                  .addi        (IsAddi), 
    //                  .control_out (control_out[3:0]),
    //                  .ex          (ex)
    //                 );
    ALU_control AC1 (.ALUop       (control_signal[5:4]), //input
                     .funct       (instruction[5:0]),    //input
                     .control_out (control_out[3:0]),
                    );

    ALU         alu1 (.control      (control_out[3:0]),
                      .a            (REG_data_out[31:0]), 
                      .b            (ALUSRC[31:0]),
                      .result_out   (result_out[31:0]),
                      .status_out   (status_out[7:0]) //trạng thái của phép tín htrong alu
                     );

    DMEM        d1( .DMEM_address   (result_out[31:0]),
                    .DMEM_data_in   (REG_data_out2[31:0]), 
                    .DMEM_mem_write (MemWrite_signal), //tín hiệu điều khiển cho phép ghi
                    .DMEM_mem_read  (MemRead_signal),  //tín hiệu điều khiển cho phép đọc
                    .clk            (SYS_clk), 
                    .DMEM_data_out  (DMEM_data_out[31:0])
                    );

    always @(negedge clk , posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            PC <= 32'b0; //các output trở về zero nữa
        end
        else
            PC <= PC + 4;
    end





    assign Branch = (status_out[7] && branch_signal)        ? 
                    (PC + 4) + (Out_SignedExtended[7:0]<<2) : 
                    PC + 4;

    assign Mem2Reg = (Mem2Reg_signal)? DMEM_data_out : result_out;
    assign ALUSRC = (ALUsrc_signal)?Out_SignedExtended[31:0]:REG_data_out2[31:0];
    assign RDst = (RegDst_signal)? instruction[15:11]:instruction[20:16];


    SignedExtended SE1 (instruction[15:0], Out_SignedExtended[31:0]);
    
    Ex4to6 e1(instruction[3:0], Ex4to6_out[5:0]);


    assign SYS_leds =   (SYS_reset)           ? 0                     :
                        (SYS_output_sel == 0) ? instruction           :
                        (SYS_output_sel == 1) ? REG_data_out          :
                        (SYS_output_sel == 2) ? result_out            :
                        (SYS_output_sel == 3) ? {19'b0, status_out}   :
                        (SYS_output_sel == 4) ? DMEM_data_out         :
                        (SYS_output_sel == 5) ? {16'b0,control_signal}:
                        (SYS_output_sel == 6) ? {ex, control_out}     :
                        (SYS_output_sel == 7) ? {PC, EPC}             : {27{1'bx}}; //cần bổ sung trường hợp không có gì
endmodule





    // wire [7:0] PC_in;
    // wire [7:0] PC_out;
    // wire [7:0] PCPlus4;
    // wire [7:0] PC_in_real;
    
    // assign PC_in_real = (SYS_reset) ? 0         :
    //                     (SYS_load)  ? SYS_pc_val:
    //                     PC_in;

    // assign PC_in = (control_signal[10])?{PCPlus4[7:6], Ex4to6_out[5:0]}:Branch;

    // PC pc1 (.clk(SYS_clk), .PC_in(PC_in_real), .PC_out(PC_out));

    // assign PCPlus4 = PC_out + 4;



    //exception zone
    // wire Exception_out;
    // assign MemRead = (Exception_out)?0:MemRead_signal;
    // assign MemWrite = (Exception_out)?0:MemWrite_signal;
    // assign MemtoReg = (Exception_out)?0:Mem2Reg_signal;
    // Exception ex1(exception_signal, ex,status_out[2],status_out[3],status_out[6],Exception_out);
    // always @(posedge Exception_out)
    // begin
    //     EPC <= (Exception_out) ? PC : EPC;
    // end