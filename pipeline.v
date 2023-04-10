//b1, không có branch và các hazard
//chỉ là kiến trúc cơ bản chỉ có lệnh R
//chưa làm theo yêu cầu cơ bản của đ�? thầy

module system(
    input   SYS_clk,
    input   SYS_reset
    // input SYS_load,
    // input [7:0] SYS_pc_val,
    // input [7 :0] SYS_output_sel,
    // output[26:0] SYS_leds,

);
    reg [4:0] test_address_register; //chỉ dành cho test, test xong xóa, để xem địa chỉ register đã chạy đúng chưa
    wire [31:0] test_value_register;          //chỉ dành cho test, test xong xóa, để xem giá trị register đã chạy đúng chưa

    //FETCH stage OK
    wire [10:0] D_control_signal;       //OK
    wire        D_isEqual_onBranch;     //tín hiệu so sánh 2 hạng tử của branch ở decode stage
    wire [31:0] D_PC;

    reg [31:0] PC;

    always @(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
            PC <= 0;
        else
        begin
            if      (D_control_signal[9])    //là branch signal, được giải quyết ở Decode stage
            begin
                if      (D_instruction[31:26] == 6'h4 &&  D_isEqual_onBranch ) //beq
                    PC <=  D_PC + 4 + (D_Out_SignedExtended[7:0]<<2);
                else if (D_instruction[31:26] == 6'h5 && !D_isEqual_onBranch ) //bne
                    PC <=  D_PC + 4 + (D_Out_SignedExtended[7:0]<<2);
                else 
                    PC <= PC + 4;
            end

            else if (D_control_signal[10])  //lệnh jump
                PC <= {D_PC[31:28], D_instruction[25:0] ,2'b00};

            else
                PC <= PC + 4;
        end
    end

    wire [31:0] F_instruction;
    IMEM imem (.IMEM_PC(PC), .IMEM_instruction(F_instruction)); //đ�?c lấy lệnh ra

    //DECODE stage
    wire [31:0] D_instruction;          //OK, fixed
    wire [31:0] D_REG_data_out1;        //chưa biết đúng sai, tạm th�?i là đúng
    wire [31:0] D_REG_data_out2;        //chưa biết đúng sai, tạm th�?i là đúng    
    wire [4:0]  D_write_register;       //OK, đúng cho cả addi và lw
    wire [31:0] D_Out_SignedExtended;   //tạm th�?i ok, trong trư�?ng hợp đơn giản
    wire        WB_RegWrite_signal;
    wire [4:0]  WB_write_register;
    wire [31:0] WB_write_data;
    decode_stage decode (//INPUT
                         .SYS_clk               (SYS_clk),
                         .SYS_reset             (SYS_reset),
                         .F_instruction         (F_instruction),
                         .F_PC                  (PC),
                         .WB_RegWrite_signal    (WB_RegWrite_signal),
                         .WB_write_register     (WB_write_register),
                         .WB_write_data         (WB_write_data),
                         .test_address_register (test_address_register),
                         //OUTPUT
                         .D_instruction         (D_instruction),
                         .D_control_signal      (D_control_signal),
                         .D_REG_data_out1       (D_REG_data_out1),
                         .D_REG_data_out2       (D_REG_data_out2),
                         .D_write_register      (D_write_register),
                         .D_Out_SignedExtended  (D_Out_SignedExtended),
                         .test_value_register   (test_value_register),
                         .D_PC                  (D_PC),
                         .D_isEqual_onBranch    (D_isEqual_onBranch)
                        );

    //EXECUTION stage
    wire [31:0] EX_instruction;     //OK
    wire [4:0]  EX_write_register;  //OK
    wire [10:0] EX_control_signal;  //OK, như đặc tả
    wire [31:0] EX_ALUresult;       //OK   
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
                        .MEM_ALUresult          (MEM_ALUresult),            //forward
                        .EX_to_MEM_forwardSignal(EX_to_MEM_forwardSignal),  //forward
                        //OUTPUT
                        .EX_instruction         (EX_instruction), 
                        .EX_control_signal      (EX_control_signal),
                        .EX_ALUresult           (EX_ALUresult),
                        .EX_operand2            (EX_operand2),
                        .EX_write_register      (EX_write_register)
                      );

    //MEMORY stage
    wire [10:0] MEM_control_signal; //ok
    wire [31:0] MEM_ALUresult;      //OK
    wire [31:0] MEM_read_data;      //OK
    wire [4:0]  MEM_write_register; //OK
    wire [31:0] MEM_instruction;    //OK, 
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
                        .MEM_write_register (MEM_write_register),
                        .MEM_instruction    (MEM_instruction)
                      );

    //Write Back stage
    
    WB_stage WB (//INPUT
                .SYS_clk            (SYS_clk),
                .SYS_reset          (SYS_reset),
                .MEM_control_signal (MEM_control_signal),
                .MEM_read_data      (MEM_read_data),
                .MEM_ALUresult      (MEM_ALUresult),
                .MEM_write_register (MEM_write_register),
                //OUTPUT
                .WB_write_data      (WB_write_data),        //OK
                .WB_RegWrite_signal (WB_RegWrite_signal),   //OK
                .WB_write_register  (WB_write_register)     //ok
                );


    //data hazard
    reg [1:0] EX_to_MEM_forwardSignal;

    always @(MEM_instruction, EX_instruction)
    begin
        if (!MEM_instruction[31:28])     //lenh trong MEM la lenh R)
        begin
            if      (!EX_instruction[31:28]) //R
            begin
                if      (MEM_instruction[15:11] == EX_instruction[25:21]) //rd == rs
                    EX_to_MEM_forwardSignal <= 2'b10;
                else if (MEM_instruction[15:11] == EX_instruction[20:16]) //rd == rt
                    EX_to_MEM_forwardSignal <= 2'b01;
                else
                    EX_to_MEM_forwardSignal <= 2'b00;                   //khong forward
            end

            else if (EX_instruction[31:28] == 4'b1000 || EX_instruction[31:26] == 6'b001000 || EX_instruction[31:28]==4'b1010) //load and addi and store
            begin
                if      (MEM_instruction[15:11] == EX_instruction[25:21])   //rd == rs
                    EX_to_MEM_forwardSignal <= 2'b10;                      
                else
                    EX_to_MEM_forwardSignal <= 2'b00;
            end

            else
                EX_to_MEM_forwardSignal <= 2'b00;
        end

        else if (MEM_instruction[31:26] == 6'b001000) //neu lenh trong MEM la addi
        begin
            if      (!EX_instruction[31:28]) //R
            begin
                if      (MEM_instruction[20:16] == EX_instruction[25:21]) //rt == rs
                    EX_to_MEM_forwardSignal <= 2'b10;
                else if (MEM_instruction[20:16] == EX_instruction[20:16]) //rt == rt
                    EX_to_MEM_forwardSignal <= 2'b01;
                else
                    EX_to_MEM_forwardSignal <= 2'b00;
            end


            else if (EX_instruction[31:28] == 4'b1000 || EX_instruction[31:26] == 6'b001000 || EX_instruction[31:28]==4'b1010) //load and addi and store
            begin
                if      (MEM_instruction[20:16] == EX_instruction[25:21])   //rd == rs
                    EX_to_MEM_forwardSignal <= 2'b10;                      
                else
                    EX_to_MEM_forwardSignal <= 2'b00;
            end

            else
                EX_to_MEM_forwardSignal <= 2'b00;   //nothing
        end

        else
            EX_to_MEM_forwardSignal <= 2'b00;
    end


endmodule


module decode_stage (
    input             SYS_clk,
    input             SYS_reset,
    input [31:0]      F_instruction,
    input [31:0]      F_PC,
    input             WB_RegWrite_signal,
    input [4:0]       WB_write_register,
    input [31:0]      WB_write_data,  
    input [4:0] test_address_register, //chỉ dành cho test, test xong xóa, để xem địa chỉ register đã chạy đúng chưa


    output reg [31:0] D_instruction,    //lưu giữ instruction để handle được hazard
    output     [10:0] D_control_signal, //cứ lưu giữ hết tất cả các tín hiệu control
    output     [31:0] D_REG_data_out1,
    output     [31:0] D_REG_data_out2,
    output     [4:0]  D_write_register,
    output     [31:0] D_Out_SignedExtended,
    output reg [31:0] D_PC,
    output            D_isEqual_onBranch,   //tín hiệu so sánh branch sớm được đưa lên decode stage

    output [31:0] test_value_register          //chỉ dành cho test, test xong xóa, để xem giá trị register đã chạy đúng chưa
       
);
    always @(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            D_instruction <= 0;
            D_PC          <= 0;
        end
        
        else
        begin
            D_instruction <= F_instruction;
            D_PC          <= F_PC;
        end
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

                 .test_address_register (test_address_register), //chỉ dành cho test, test xong xóa, để xem địa chỉ register đã chạy đúng chưa

                 //OUTPUT
                 .REG_data_out1   (D_REG_data_out1), //giá trị rs đ�?c được để đưa vào tính toán
                 .REG_data_out2   (D_REG_data_out2), //giá trị rt đ�?c được để đưa vào tính toán
                 .test_value_register (test_value_register)
                 );
    assign D_isEqual_onBranch = (D_REG_data_out1 == D_REG_data_out2);
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
    input      [31:0] MEM_ALUresult,            //forward
    input      [1:0]  EX_to_MEM_forwardSignal,  //forward

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

    always @(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            EX_instruction        <= 0;
            EX_control_signal     <= 0;
            EX_operand1           <= 0;
            EX_operand2           <= 0;
            EX_Out_SignedExtended <= 0;
            EX_write_register     <= 0;
        end

        else
        begin
            EX_instruction        <= D_instruction;
            EX_control_signal     <= D_control_signal;
            EX_operand1           <= D_REG_data_out1;
            EX_operand2           <= D_REG_data_out2;
            EX_Out_SignedExtended <= D_Out_SignedExtended;
            EX_write_register     <= D_write_register;
        end
    end

    ALU_control AC1 (.ALUop       (EX_control_signal[5:4]), //input
                     .funct       (EX_instruction   [5:0]), //input
                     .control_out (alu_control      [3:0]) //output
                    );
    assign ALUSRC[31:0] = (EX_control_signal[2])             ? EX_Out_SignedExtended[31:0] : 
                          (EX_to_MEM_forwardSignal == 2'b01) ? MEM_ALUresult               : EX_operand2[31:0]; //quyết định ch�?n trư�?ng nhập vào ALU tùy theo R hay I
    
    wire [31:0] rs;
    assign rs = (EX_to_MEM_forwardSignal == 2'b10) ?  MEM_ALUresult : EX_operand1;//decide to forward

    ALU         alu1 (//INPUT
                      .control      (alu_control[3:0]),
                      .a            (rs), //rs in
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

    output reg [10:0] MEM_control_signal,
    output reg [31:0] MEM_ALUresult,
    output     [31:0] MEM_read_data,
    output reg [4:0]  MEM_write_register,
    output reg [31:0] MEM_instruction
);
    reg [31:0] MEM_write_data;

    always@(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            MEM_instruction    <= 0;
            MEM_control_signal <= 0;
            MEM_ALUresult      <= 0;
            MEM_write_data     <= 0;
            MEM_write_register <= 0;
        end

        else
        begin
            MEM_instruction    <= EX_instruction;
            MEM_control_signal <= EX_control_signal;
            MEM_ALUresult      <= EX_ALUresult;
            MEM_write_data     <= EX_operand2;
            MEM_write_register <= EX_write_register;
        end
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
    input      [10:0] MEM_control_signal,
    input      [31:0] MEM_read_data,
    input      [31:0] MEM_ALUresult,
    input      [4:0]  MEM_write_register,

    output     [31:0] WB_write_data,
    output            WB_RegWrite_signal,
    output reg [4:0]  WB_write_register
);
    reg [10:0] WB_control_signal;
    reg [31:0] WB_read_data;
    reg [31:0] WB_ALUresult;

    always @(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            WB_control_signal <= 0;
            WB_read_data      <= 0;
            WB_ALUresult      <= 0;
            WB_write_register <= 0;
        end
        
        else
        begin
            WB_control_signal <= MEM_control_signal;
            WB_read_data      <= MEM_read_data;
            WB_ALUresult      <= MEM_ALUresult;
            WB_write_register <= MEM_write_register;
        end
    end

    assign WB_RegWrite_signal = WB_control_signal[1];
    assign WB_write_data =  (WB_control_signal[6]) ? WB_read_data : WB_ALUresult;
endmodule