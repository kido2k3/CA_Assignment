`timescale 1ns / 1ps

module system(
input SYS_clk,
input SYS_reset,
input SYS_load,
input [7:0] SYS_pc_val,
input [7 :0] SYS_output_sel,
output[26:0] SYS_leds
);
    
    wire [7:0] PC_in;
    wire [7:0] PC_out;
    
    wire [31:0] IMEM_ins;
    wire [4:0]RDst;
    wire [31:0] REG_data_out;
    wire [31:0] REG_data_out2;
    wire [10:0] control_signal;
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
    wire [7:0] PCPlus4;
    wire Exception_out;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire [7:0] PC_in_real;
    reg [7:0] EPC;
    
    initial EPC=0;
    always @(posedge Exception_out)
        begin
        EPC = (Exception_out) ? PC_out:EPC;
        end
    assign MemRead = (Exception_out)?0:control_signal[8];
    assign MemWrite = (Exception_out)?0:control_signal[7];
    assign MemtoReg = (Exception_out)?0:control_signal[6];
    assign PCPlus4 = PC_out + 4;

    assign Branch = (status_out[7] && control_signal[9])? 
        (PC_out + 4) + (Out_SignedExtended[7:0]<<2) : 
        PC_out + 4;
    assign Mem2Reg = (MemtoReg)? DMEM_data_out : result_out;
    assign ALUSRC = (control_signal[2])?Out_SignedExtended[31:0]:REG_data_out2[31:0];
    assign RDst = (control_signal[0])? IMEM_ins[15:11]:IMEM_ins[20:16];

    assign PC_in = (control_signal[10])?{PCPlus4[7:6], Ex4to6_out[5:0]}:Branch;

    PC pc1 (.clk(SYS_clk), .PC_in(PC_in_real), .PC_out(PC_out));
    IMEM imem (.IMEM_PC(PC_out), .IMEM_instruction(IMEM_ins));
    REG Reg1 (.REG_address1( IMEM_ins[25:21]), .REG_address2(IMEM_ins[20:16]),
                            .REG_address_wr(RDst),.REG_write_1(control_signal[1]),
                            .REG_data_wb_in1(Mem2Reg),
                            .clk(SYS_clk),
                            .REG_data_out1(REG_data_out[31:0]),
                            .REG_data_out2(REG_data_out2[31:0])
                            );
    control crl1 (IMEM_ins[31:26],IMEM_ins[15:11],IMEM_ins[20:16],control_signal[10:0], IsAddi);
    SignedExtended SE1 (IMEM_ins[15:0], Out_SignedExtended[31:0]);
    ALU_control AC1(control_signal[5:4], IMEM_ins[5:0], IsAddi, control_out[3:0], ex);
    ALU alu1 (control_out[3:0], REG_data_out[31:0], ALUSRC[31:0], result_out[31:0], status_out[7:0]);
    DMEM d1(result_out[31:0], REG_data_out2[31:0], MemWrite, MemRead, SYS_clk, DMEM_data_out[31:0]);
    Ex4to6 e1(IMEM_ins[3:0], Ex4to6_out[5:0]);
    Exception ex1(control_signal[3], ex,status_out[2],status_out[3],status_out[6],Exception_out);
    
    assign PC_in_real = (SYS_reset)?0:
                        (SYS_load)?SYS_pc_val:
                        PC_in;

    assign SYS_leds =   (SYS_reset)?0:
                        (!SYS_output_sel)?IMEM_ins:
                        (SYS_output_sel==1)?REG_data_out:
                        (SYS_output_sel==2)?result_out:
                        (SYS_output_sel==3)?{19'b0, status_out}:
                        (SYS_output_sel==4)?DMEM_data_out:
                        (SYS_output_sel==5)?{16'b0,control_signal}:
                        (SYS_output_sel==6)?{ex, control_out}: {PC_out, EPC};
endmodule
