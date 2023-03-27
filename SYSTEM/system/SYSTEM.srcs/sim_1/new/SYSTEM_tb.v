`timescale 1ns / 1ps

module SYSTEM_tb;
reg SYS_clk;
reg SYS_reset;
reg SYS_load;
reg [7:0] SYS_pc_val;
reg [7 :0] SYS_output_sel;
wire [26:0] SYS_leds;
integer i;
wire[7:0] PC_out_t;
wire [31:0] IMEM_ins_t;
wire[31:0] REG_data_out1_t;
wire[31:0] REG_data_out2_t;
wire [10:0] control_signal_t;
wire signed [31:0] result_out_t;
wire [7:0] status_out_t;
wire[31:0] DMEM_data_out_t;
wire[31:0] Mem2Reg_t;

system sy(SYS_clk,SYS_reset,SYS_load,SYS_pc_val,SYS_output_sel,SYS_leds,
          PC_out_t, IMEM_ins_t, REG_data_out1_t,REG_data_out2_t, control_signal_t,result_out_t, status_out_t, DMEM_data_out_t, Mem2Reg_t);
initial
    begin
     SYS_reset = 0;
     SYS_load = 0;

        SYS_clk=0;
        forever
        #8 SYS_clk=~SYS_clk;
  
    end  
initial
    begin
        for(i = 0; i<100; i=i+1)
            begin
              SYS_output_sel = i%8;
              #1;
            end
            $display("clk = %d reset = %d load = %d val = %b",SYS_clk, SYS_reset, SYS_load, SYS_pc_val);
            $display("sel = %b",SYS_output_sel);
            $display("leds = %b",SYS_leds);
    end          
//reg  [4:0] REG_address1;
//reg [4:0] REG_address2;
//reg [4:0] REG_address_wr; 
//reg REG_write_1;
//reg [31:0] REG_data_wb_in1; 
////reg clk,
//wire [31:0] REG_data_out1; 
//wire [31:0] REG_data_out2;    

//REG r(REG_address1,REG_address2,REG_address_wr,REG_write_1,REG_data_wb_in1,REG_data_out1,REG_data_out2);
//initial
//    begin
       
        
//        REG_address_wr = 8;
//        REG_data_wb_in1 = 1;
//        #1
//        REG_write_1 =1;
//        #5;
//        REG_write_1 =0;
        
//        REG_address_wr =9;
//        REG_data_wb_in1 =2;
//        #1
//        REG_write_1 =1;
//        #5;
//        REG_address_wr =10;
//        REG_data_wb_in1=3;
//        #5;
//        REG_address1 = 0;
//        REG_address2 = 8;
//        #5;
//        REG_address1 = 9;
//                REG_address2 = 10;
//                #5;
//    end
endmodule
