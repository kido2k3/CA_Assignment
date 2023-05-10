//b1, không có branch và các hazard
//chỉ là kiến trúc cơ bản chỉ có lệnh R
//chưa làm theo yêu cầu cơ bản của đ�? thầy

// danh sách các exception
// không xác định được lệnh -> decode stage -> 001
// ghi vào zero             -> WB           -> 100
// địa chỉ không align      -> MEM          
// tràn số                  -> EXE ALU
// chia cho 0               -> EXE ALU

module freq_divider(
    input SYS_clk, SYS_reset,
    output reg divided_clk
);
    parameter divisor = 250_000_000;
    parameter m = divisor/2;
    integer count;
    
    always @(negedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            count        <= 0;
            divided_clk  <= 1;
        end

        else
        begin
            if (count >= m)
            begin
                count        <= 0;
                divided_clk  <= ~divided_clk;
            end
            else count <= count + 1;
        end
    end
endmodule


module system(
    input   clk,
    input   SYS_reset,
    input [2:0]  SYS_output_sel, //trong �'�? l�  7 bit nhưng chỉ cần 3 bit l�  �'ủ hiện thực
    
    output CLK_led,
    output[26:0] SYS_leds
);
    wire SYS_clk;
    parameter divisor = 250_000_000;
    freq_divider #(.divisor(divisor))divide(clk, SYS_reset, SYS_clk);
    //---------------------------------------------------------------------
    wire[31:0] testt_reg;
    //chi de test
    //khi chay that; sua tat ca thanh output; reg; xoa output di
    reg       SYS_load;
    reg [7:0]  SYS_pc_val;
    //FETCH stage OK
    wire [7:0] PC;
    wire [31:0] F_instruction;

    //DECODE stage
    wire [31:0] D_instruction;          //OK; fixed
    wire [31:0] D_REG_data_out1;        //chưa biết đúng sai; tạm th�?i là đúng
    wire [31:0] D_REG_data_out2;        //chưa biết đúng sai; tạm th�?i là đúng    
    wire [4:0]  D_write_register;       //OK; đúng cho cả addi và lw
    wire [31:0] D_Out_SignedExtended;   //tạm th�?i ok; trong trư�?ng hợp đơn giản
    wire [10:0] D_control_signal;       //OK
    wire        D_isEqual_onBranch;     //tín hiệu so sánh 2 hạng tử của branch ở decode stage
    wire [ 7:0] D_PC;
    wire        branch_taken;
    wire        D_jump_signal;
    
    //EXECUTION stage
    wire [31:0] EX_instruction;     //OK
    wire [4:0]  EX_write_register;  //OK
    wire [10:0] EX_control_signal;  //OK; như đặc tả
    wire [31:0] EX_ALUresult;       //OK   
    wire [31:0] EX_operand2;
    wire [31:0] EX_forwarded_operand2;
    wire [ 7:0] EX_PC;
    wire EX_non_align_word;
    wire [7:0] EX_status_out;
    wire [3:0]  EX_alu_control;
    wire [31:0] EX_b_operand, EX_a_operand;


    //MEMORY stage
    wire [10:0] MEM_control_signal; //ok
    wire [31:0] MEM_ALUresult;      //OK
    wire [31:0] MEM_read_data;      //OK
    wire [4:0]  MEM_write_register; //OK
    wire [31:0] MEM_instruction;    //OK; 
    wire [ 7:0] MEM_PC;

    //Write Back stage
    wire        WB_RegWrite_signal;
    wire [4:0]  WB_write_register;
    wire [31:0] WB_write_data;
    wire [31:0] WB_instruction;
    wire [ 7:0] WB_PC;

    //for exception
    wire [ 7:0] EPC;
    wire interrupt_signal;
    wire [7:0] commit_PC;

    //data hazard
    wire [1:0] MEM_to_D_forwardSignal;
    wire [1:0] MEM_to_EX_forwardSignal;

    wire D_stall; //biến dùng chỉ để nên stall ở Decode stage hay không

    //exception detection
    wire [2:0] D_exception_signal, MEM_exception_signal, WB_exception_signal, EX_exception_signal;
    //khối theo thầy yêu cầu


    wire  [31:0] testt_reg_add = 8;

    assign CLK_led = SYS_clk;

    assign SYS_leds =   (SYS_reset)           ? 0                       :
                        // (SYS_output_sel == 0) ? F_instruction           :
                        (SYS_output_sel == 0) ? testt_reg               :
                        (SYS_output_sel == 1) ? D_REG_data_out1         :
                        (SYS_output_sel == 2) ? EX_ALUresult            :
                        (SYS_output_sel == 3) ? {19'b0, EX_status_out}  :
                        (SYS_output_sel == 4) ? MEM_read_data           :
                        (SYS_output_sel == 5) ? {16'b0,D_control_signal}:
                        (SYS_output_sel == 6) ? EX_alu_control          :
                        (SYS_output_sel == 7) ? {PC, EPC}               : {27{1'b0}}; //cần bổ sung trư�?ng hợp không có gì
    dependency_detection dependency_unit(
        //INPUT
        .D_instruction  (D_instruction),
        .EX_instruction (EX_instruction),
        .MEM_instruction(MEM_instruction),
        //OUTPUT
        .D_stall        (D_stall)
    );

    forward_detection forward_unit(
        .MEM_instruction        (MEM_instruction),
        .D_instruction          (D_instruction),
        .EX_instruction         (EX_instruction),

        .MEM_to_EX_forwardSignal(MEM_to_EX_forwardSignal),
        .MEM_to_D_forwardSignal (MEM_to_D_forwardSignal)
    );

    fetch_stage  fetch (
        //INPUT
        .SYS_clk                (SYS_clk),
        .SYS_reset              (SYS_reset),
        .interrupt_signal       (interrupt_signal),
        .D_Out_SignedExtended   (D_Out_SignedExtended),
        .D_instruction          (D_instruction),
        .D_PC                   (D_PC),
        .D_stall                (D_stall),
        .D_jump_signal          (D_control_signal[10]),
        .branch_taken           (branch_taken),
        .SYS_load               (SYS_load),
        .SYS_pc_val             (SYS_pc_val),
        //OUTPUT
        .PC                     (PC),
        .F_instruction          (F_instruction)
    );

    decode_stage decode (//INPUT
        .SYS_clk               (SYS_clk),
        .SYS_reset             (SYS_reset),
        .interrupt_signal      (interrupt_signal),
        .F_instruction         (F_instruction),
        .F_PC                  (PC),
        .WB_RegWrite_signal    (WB_RegWrite_signal),
        .WB_write_register     (WB_write_register),
        .WB_write_data         (WB_write_data),
        .D_stall               (D_stall),
        .MEM_to_D_forwardSignal(MEM_to_D_forwardSignal),   //forward
        .MEM_ALUresult         (MEM_ALUresult),            //forward 
        //OUTPUT
    .D_exception_instruction   (D_instruction),
    .D_exception_control_signal(D_control_signal),
        .D_REG_data_out1       (D_REG_data_out1),
        .D_REG_data_out2       (D_REG_data_out2),
        .D_write_register      (D_write_register),
        .D_Out_SignedExtended  (D_Out_SignedExtended),
        .D_PC                  (D_PC),
        .branch_taken          (branch_taken),
        .D_exception_signal    (D_exception_signal),
        .testt_reg_add(testt_reg_add),
        .testt_reg(testt_reg)
    );

    execution_stage EX(//INPUT
        .SYS_clk                (SYS_clk),
        .SYS_reset              (SYS_reset),
        .interrupt_signal       (interrupt_signal),
        .D_instruction          (D_instruction),
        .D_control_signal       (D_control_signal),
        .D_REG_data_out1        (D_REG_data_out1),
        .D_REG_data_out2        (D_REG_data_out2),
        .D_write_register       (D_write_register),
        .D_Out_SignedExtended   (D_Out_SignedExtended),
        .D_stall                (D_stall),
        .D_exception_signal     (D_exception_signal),
        .D_PC                   (D_PC),
        .MEM_to_EX_forwardSignal(MEM_to_EX_forwardSignal),
        .MEM_ALUresult          (MEM_ALUresult),
        //OUTPUT
    .EX_exception_instruction   (EX_instruction), 
    .EX_exception_control_signal(EX_control_signal),
        .EX_ALUresult           (EX_ALUresult),
        .EX_operand2            (EX_operand2),
        .EX_forwarded_operand2  (EX_forwarded_operand2),
        .EX_write_register      (EX_write_register),
        .EX_exception_signal    (EX_exception_signal),
        .EX_PC                  (EX_PC),
        .EX_non_align_word      (EX_non_align_word),
        .status_out             (EX_status_out),
        .alu_control            (EX_alu_control),
        .ALUSRC                 (EX_b_operand),
        .rs                     (EX_a_operand)
    );

    memory_stage MEM  (//INPUT
            .SYS_clk            (SYS_clk),
            .SYS_reset          (SYS_reset),
            .interrupt_signal   (interrupt_signal),
            .EX_instruction     (EX_instruction),
            .EX_write_register  (EX_write_register),
            .EX_control_signal  (EX_control_signal),
            .EX_ALUresult       (EX_ALUresult),
            .EX_forwarded_operand2(EX_forwarded_operand2),
            .EX_exception_signal(EX_exception_signal),
            .EX_non_align_word  (EX_non_align_word),
            .EX_PC              (EX_PC),
            //OUTPUT
  .MEM_exception_control_signal (MEM_control_signal),
            .MEM_ALUresult      (MEM_ALUresult),
            .MEM_read_data      (MEM_read_data),
            .MEM_write_register (MEM_write_register),
     .MEM_exception_instruction (MEM_instruction),
           .MEM_exception_signal(MEM_exception_signal),
           .MEM_PC              (MEM_PC)
    );

    WB_stage WB (//INPUT
        .SYS_clk            (SYS_clk),
        .SYS_reset          (SYS_reset),
        .interrupt_signal   (interrupt_signal),
        .MEM_control_signal (MEM_control_signal),
        .MEM_read_data      (MEM_read_data),
        .MEM_ALUresult      (MEM_ALUresult),
        .MEM_write_register (MEM_write_register),
        .MEM_instruction    (MEM_instruction),
       .MEM_exception_signal(MEM_exception_signal),
        .MEM_PC             (MEM_PC),
        //OUTPUT
        .WB_instruction     (WB_instruction),
        .WB_write_data      (WB_write_data),        //OK
        .WB_RegWrite_signal (WB_RegWrite_signal),   //OK
        .WB_write_register  (WB_write_register),     //ok
        .WB_exception_signal(WB_exception_signal),
        .WB_PC              (WB_PC)
    );

    exception_handle interrupt(
        //INPUT
        .SYS_clk                (SYS_clk),
        .SYS_reset              (SYS_reset),
        .WB_exception_signal    (WB_exception_signal),
        .WB_PC                  (WB_PC),
        //OUTPUT
        .EPC                    (EPC),
        .commit_PC              (commit_PC),
        .interrupt_signal       (interrupt_signal)
    );


endmodule

module fetch_stage(
    input             SYS_clk,
    input             SYS_reset,
    input             interrupt_signal,
    input      [31:0] D_Out_SignedExtended,
    input      [31:0] D_instruction,
    input      [ 7:0] D_PC,

    input             D_stall,
    input             D_jump_signal,
    input             branch_taken,

    input             SYS_load,
    input       [7:0] SYS_pc_val,

    output reg [7:0]  PC,
    output     [31:0] F_instruction
);

    always @(negedge SYS_clk, posedge SYS_reset, posedge interrupt_signal)
    begin
        if (SYS_reset || interrupt_signal)
        begin
            PC  <= 0;
        end

        else
        begin
            if      (SYS_load)      //lệnh của ngư�?i dùng
                PC[7:0] <= SYS_pc_val;
            else if (D_stall)  //khong lam gi neu dang co stall
                PC <= PC;
            else if (branch_taken)    //là branch signal, được giải quyết ở Decode stage
                PC <=  D_PC + 1 + (D_Out_SignedExtended);

            else if (D_jump_signal)  //lệnh jump 
                PC <= D_instruction[7:0] ;

            else
                PC <= PC + 1;
        end
    end

    IMEM imem (.IMEM_PC(PC), .IMEM_instruction(F_instruction)); //đ�?c lấy lệnh ra

endmodule


module decode_stage (
    input             SYS_clk,
    input             SYS_reset,
    input [31:0]      F_instruction,
    input [7:0]       F_PC,
    input             WB_RegWrite_signal,
    input [4:0]       WB_write_register,
    input [31:0]      WB_write_data,  
    input             D_stall,
    input [31:0]      MEM_ALUresult,    //forward
    input [1:0]       MEM_to_D_forwardSignal,
    input             interrupt_signal,

    
    wire       [31:0] D_exception_instruction,    //ch�?n l�?c lại
    wire       [10:0] D_exception_control_signal, //ch�?n l�?c lại qua exception
    output     [31:0] D_REG_data_out1,
    output     [31:0] D_REG_data_out2,
    output     [4:0]  D_write_register,
    output     [31:0] D_Out_SignedExtended,
    output reg [7:0]  D_PC,
    output            branch_taken,
    output     [2:0]  D_exception_signal,
    input [31:0]   testt_reg_add,
    output [31:0]   testt_reg

);
    reg  [31:0] D_instruction;    //lưu giữ instruction để handle được hazard, đây là tín hiệu được ban đầu nhưng output là thứ dã qua ch�?n l�?c
    wire [10:0] D_control_signal; //cứ lưu giữ hết tất cả các tín hiệu control
    wire [31:0] operand1;
    wire [31:0] operand2;
    wire        D_isEqual_onBranch;   //tín hiệu so sánh branch sớm được đưa lên decode stage


    always @(negedge SYS_clk, posedge SYS_reset, posedge interrupt_signal)
    begin
        if (SYS_reset || interrupt_signal)
        begin
            D_instruction <= 0;
            D_PC          <= 0;
        end
        
        else if (D_stall)
        begin
            D_instruction <= D_instruction;
            D_PC          <= D_PC;
        end

        else if (branch_taken || D_control_signal[10])  //lệnh jump và branch, giết câu lệnh tiếp theo
        begin
            D_instruction <= 0;
            D_PC          <= F_PC;
        end

        else
        begin
            D_instruction <= F_instruction;
            D_PC          <= F_PC;
        end
    end
    
    control crl1 (.instruction    (D_instruction),//INPUT
                  .control_signal (D_control_signal)    //tín hiệu control output ra
                 );

    assign D_write_register  = (D_control_signal[0]) ? D_instruction[15:11]:D_instruction[20:16]; //nên write vào rd hay rt, tức là I hay R

    SignedExtended SE1 (D_instruction[15:0], D_Out_SignedExtended[31:0]);
    
    REG     Reg1 (//for WB stage
                 .clk             (SYS_clk),             //clock này chỉ để write ở WB
                 .SYS_reset       (SYS_reset),
                 .REG_address_wr  (WB_write_register),   //địa chỉ để ghi vào, là rd trong R, rt trong I
                 .REG_write_1     (WB_RegWrite_signal), //tín hiê ucho phép ghi hay không
                 .REG_data_wb_in1 (WB_write_data),      //dữ liệu tính toán ra được sắp được ghi vào.
                 //INPUT
                 .REG_address1    (D_instruction[25:21]), //địa chỉ rs
                 .REG_address2    (D_instruction[20:16]), //địa chỉ rt

                 
                 //OUTPUT
                 .REG_data_out1   (operand1), //giá trị rs đ�?c được để đưa vào tính toán
                 .REG_data_out2   (operand2), //giá trị rt đ�?c được để đưa vào tính toán
                 .testt_reg_add(testt_reg_add),
                 .testt_reg(testt_reg)
                 );
    
    assign D_REG_data_out1 = (MEM_to_D_forwardSignal[1]) ? MEM_ALUresult : operand1;    //choose betwwen forward from MEM or not
    assign D_REG_data_out2 = (MEM_to_D_forwardSignal[0]) ? MEM_ALUresult : operand2;

    assign D_isEqual_onBranch = (D_REG_data_out1 == D_REG_data_out2);
    assign branch_taken = D_control_signal[9] && ((D_instruction[31:26] == 6'h4 &&  D_isEqual_onBranch) || 
                                                  (D_instruction[31:26] == 6'h5 && !D_isEqual_onBranch ));
    
    assign D_exception_signal         = (D_control_signal[3]) ? 3'b001 : 3'b0;
    assign D_exception_instruction    = (D_exception_signal)  ? 32'b0  : D_instruction;       //ch�?n l�?c lại, thứ được đưa ra ngoài là thứ đã được xử lý
    assign D_exception_control_signal = (D_exception_signal)  ? 32'b0  : D_control_signal;    //ch�?n l�?c lại, thứ được đưa ra ngoài là thứ đã được xử lý
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
    input             D_stall, 
    input      [2:0]  D_exception_signal,
    input      [ 7:0] D_PC,
    input             interrupt_signal,
    input      [1:0]  MEM_to_EX_forwardSignal,
    input      [31:0] MEM_ALUresult,

    output reg [ 7:0] EX_PC,
    output            EX_non_align_word, //tín hiệu để giành cho MEM stage nếu đây là lệnh load hoặc store
    output     [2:0]  EX_exception_signal,
    output     [10:0] EX_exception_control_signal,
    output     [31:0] EX_exception_instruction,
    output     [31:0] EX_ALUresult,
    output reg [31:0] EX_operand2,
    output     [31:0] EX_forwarded_operand2,
    output reg [4:0]  EX_write_register,  //để sử dụng ở WB
    output [7:0] status_out,
    output [3:0] alu_control,

    output [31:0] ALUSRC,
    output [31:0] rs
);
    reg [2:0]  pre_exception_signal;    //dùng để giữ tín hiệu exception ở câu lệnh trước, nhưng không phải thứ sẽ xuất ra
    reg [31:0] EX_instruction;
    reg [10:0] EX_control_signal;
    reg [31:0] EX_operand1;
    reg [31:0] EX_Out_SignedExtended;

    always @(negedge SYS_clk, posedge SYS_reset, posedge interrupt_signal)
    begin
        if (SYS_reset || D_stall || interrupt_signal)
        begin
            EX_instruction        <= 0;
            EX_control_signal     <= 0;
            EX_operand1           <= 0;
            EX_operand2           <= 0;
            EX_Out_SignedExtended <= 0;
            EX_write_register     <= 0;
            pre_exception_signal  <= 0;
            EX_PC                 <= 0;
        end

        else
        begin
            EX_instruction        <= D_instruction;
            EX_control_signal     <= D_control_signal;
            EX_operand1           <= D_REG_data_out1;
            EX_operand2           <= D_REG_data_out2;
            EX_Out_SignedExtended <= D_Out_SignedExtended;
            EX_write_register     <= D_write_register;
            pre_exception_signal  <= D_exception_signal;
            EX_PC                 <= D_PC;
        end
    end

    ALU_control AC1 (.ALUop       (EX_control_signal[5:4]), //input
                     .funct       (EX_instruction   [5:0]), //input
                     .opcode       (EX_instruction[31:26]), //lệnh srl và mul chỉ khác nhau ở opcode, cùng funct nên đưa thêm opcode vào để quyết định alu control signal

                     .control_out (alu_control      [3:0]) //output
                    );

    assign ALUSRC[31:0] = (EX_control_signal[2])       ? EX_Out_SignedExtended[31:0] : 
                          (MEM_to_EX_forwardSignal[0]) ? MEM_ALUresult               : EX_operand2[31:0];
    
    assign EX_forwarded_operand2 = (MEM_to_EX_forwardSignal[0]) ? MEM_ALUresult : EX_operand2[31:0];
    
    assign rs = (MEM_to_EX_forwardSignal[1] ) ?  MEM_ALUresult :  EX_operand1;//decide to forward

    ALU         alu1 (//INPUT
                      .control      (alu_control[3:0]),
                      .a            (rs), //rs in
                      .b            (ALUSRC[31:0]),       //rt or imm
                      .shamt        (EX_instruction[10:6]),
                      //OUTPUT
                      .result_out   (EX_ALUresult[31:0]),
                      .status_out   (status_out) //trạng thái của phép tín htrong alu
                     );

    //xử lý exception
    assign EX_exception_signal         = (pre_exception_signal)            ? pre_exception_signal :    //nếu ở trước có thì lấy ở trước
                                         (status_out[2] ||  status_out[6]) ? 3'b010               : 3'b0;
   
    assign EX_exception_control_signal = (EX_exception_signal) ? 11'b0 : EX_control_signal;
    assign EX_exception_instruction    = (EX_exception_signal) ? 32'b0 : EX_instruction;            //ch�?n l�?c
    assign EX_non_align_word           = status_out[3];
endmodule


module memory_stage (
    input             SYS_clk,
    input             SYS_reset,
    input      [31:0] EX_instruction, 
    input      [4:0]  EX_write_register,
    input      [10:0] EX_control_signal,
    input      [31:0] EX_ALUresult,
    input      [31:0] EX_forwarded_operand2,
    input             EX_non_align_word,
    input      [2:0]  EX_exception_signal,
    input      [ 7:0] EX_PC,
    input             interrupt_signal,

    output reg [ 7:0] MEM_PC,
    output     [2:0]  MEM_exception_signal,
    output     [10:0] MEM_exception_control_signal,
    output reg [31:0] MEM_ALUresult,
    output     [31:0] MEM_read_data,
    output reg [4:0]  MEM_write_register,
    output     [31:0] MEM_exception_instruction
);
    reg [10:0] MEM_control_signal;
    reg [31:0] MEM_instruction;
    reg [31:0] MEM_write_data;

    reg [2:0]  pre_exception_signal;
    reg        non_align_word;

    always@(negedge SYS_clk, posedge SYS_reset, posedge interrupt_signal)
    begin
        if (SYS_reset || interrupt_signal)
        begin
            MEM_instruction    <= 0;
            MEM_control_signal <= 0;
            MEM_ALUresult      <= 0;
            MEM_write_data     <= 0;
            MEM_write_register <= 0;
            non_align_word     <= 0;
          pre_exception_signal <= 0;
            MEM_PC             <= 0;
        end

        else
        begin
            MEM_instruction    <= EX_instruction;
            MEM_control_signal <= EX_control_signal;
            MEM_ALUresult      <= EX_ALUresult;
            MEM_write_data     <= EX_forwarded_operand2;
            MEM_write_register <= EX_write_register;
            non_align_word     <= EX_non_align_word;
          pre_exception_signal <= EX_exception_signal;
            MEM_PC             <= EX_PC;
        end
    end


    DMEM    d1( //INPUT
                .DMEM_address   (MEM_ALUresult), //alu and adrress
                .DMEM_data_in   (MEM_write_data), 
                .DMEM_mem_write (MemWrite_signal), //tín hiệu đi�?u khiển cho phép ghi
                .DMEM_mem_read  (MemRead_signal),  //tín hiệu đi�?u khiển cho phép đ�?c
                .clk            (SYS_clk), 
                .SYS_reset      (SYS_reset),
                //OUTPUT
                .DMEM_data_out  (MEM_read_data)
               );
            
    //xử lý exception
    assign MEM_exception_signal = (pre_exception_signal)                     ? pre_exception_signal :
        ((MEM_control_signal[8] || MEM_control_signal[7]) && non_align_word) ? 3'b11                : 3'b0; //nếu như cho phép đ�?c ghi mà gây ra exception thì b�?

    assign MEM_exception_control_signal = (MEM_exception_signal) ? 11'b0 : MEM_control_signal;
    assign MEM_exception_instruction    = (MEM_exception_signal) ? 32'b0 : MEM_instruction;

    assign MemRead_signal = MEM_exception_control_signal[8];    //nếu đã cả ra exeption rồi thì không cho phép đ�?c ghi
    assign MemWrite_signal = MEM_exception_control_signal[7];
endmodule

module WB_stage (
    input             SYS_clk,
    input             SYS_reset,
    input      [10:0] MEM_control_signal,
    input      [31:0] MEM_read_data,
    input      [31:0] MEM_ALUresult,
    input      [4:0]  MEM_write_register,
    input      [31:0] MEM_instruction, 
    input      [2:0]  MEM_exception_signal,
    input      [ 7:0] MEM_PC,
    input             interrupt_signal,

    output     [2:0]  WB_exception_signal,
    output     [31:0] WB_write_data,
    output            WB_RegWrite_signal,
    output reg [4:0]  WB_write_register,
    output reg [ 7:0] WB_PC,
    output reg [31:0] WB_instruction
);
    reg [10:0] WB_control_signal;
    reg [31:0] WB_read_data;
    reg [31:0] WB_ALUresult;

    reg [2:0]  pre_exception_signal;

    always @(negedge SYS_clk, posedge SYS_reset, posedge interrupt_signal)
    begin
        if (SYS_reset || interrupt_signal)
        begin
            WB_control_signal <= 0;
            WB_read_data      <= 0;
            WB_ALUresult      <= 0;
            WB_write_register <= 0;
            WB_instruction    <= 0;
         pre_exception_signal <= 0;
            WB_PC             <= 0;
        end
        
        else
        begin
            WB_control_signal <= MEM_control_signal;
            WB_read_data      <= MEM_read_data;
            WB_ALUresult      <= MEM_ALUresult;
            WB_write_register <= MEM_write_register;
            WB_instruction    <= MEM_instruction;
         pre_exception_signal <= MEM_exception_signal;
            WB_PC             <= MEM_PC;
        end
    end

    assign WB_write_data =  (WB_control_signal[6]) ? WB_read_data : WB_ALUresult;

    //xử lý exception
    assign WB_exception_signal = (pre_exception_signal)      ? pre_exception_signal :
            (WB_write_register == 0 && WB_control_signal[1]) ? 3'b111               : 3'b000;

    assign WB_RegWrite_signal = (WB_exception_signal)        ? 0 : WB_control_signal[1]; //nếu có exception thì 0 ghi
endmodule

module exception_handle(
    input             SYS_clk,
    input             SYS_reset,
    input      [2:0]  WB_exception_signal,
    input      [ 7:0] WB_PC,
    output reg [7:0] commit_PC,
    output  [ 7:0] EPC,
    output         interrupt_signal
);
    reg [2:0] exception_signal;

    always @(posedge SYS_clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            exception_signal <= 0;
            commit_PC        <= 0;
        end
        
        else if (!interrupt_signal)
        begin
            exception_signal <= WB_exception_signal;
            commit_PC        <= WB_PC;
        end

        else //if (interrupt_signal) if there is old exception signal
        begin
            exception_signal <= exception_signal;
            commit_PC        <= commit_PC;
        end
    end

    assign interrupt_signal = |exception_signal;
    assign EPC              = (interrupt_signal)? commit_PC : 0;
endmodule

module dependency_detection(    //combinational circuit
    input [31:0] D_instruction,
    input [31:0] EX_instruction,
    input [31:0] MEM_instruction,

    output reg   D_stall    //biến dùng chỉ để nên stall ở Decode stage hay không
);
    reg hazard_D_EX;    //biến dùng để chỉ giữa decode và ex có phụ thuộc hay không
    reg hazard_D_MEM;   //biến dùng để chỉ giữa decode và MEM có phụ thuộc hay không

    always @(D_instruction, EX_instruction, MEM_instruction)
    begin
        hazard_D_EX = 0; //prevent latch
        hazard_D_MEM = 0;

        if (!D_instruction)  //dothing if nop
        begin
            hazard_D_EX = 0;
            hazard_D_MEM = 0;
        end

        else 
        begin
            if (!EX_instruction)
                hazard_D_EX = 0;
            else if (EX_instruction[31:28] == 4'b1000)   //neu lenh truoc la load
            begin
                if      (!D_instruction[31:26] ||  D_instruction[31:26] == 6'h1c) //if the instruction in decode is R
                begin
                    if (EX_instruction[20:16] == D_instruction[25:21] || EX_instruction[20:16] == D_instruction[20:16]) //rt == rs rt == rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;

                end
                

                else if (D_instruction[31:28] == 4'b1000 || D_instruction[31:26] == 6'b001000) //load and addi 
                begin
                    if (EX_instruction[20:16] == D_instruction[25:21])   //rt == rs
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end

                else if ( D_instruction[31:28]==4'b1010) //store, may word or half word
                begin
                    //sw rt -> offset(rs)
                    if      (EX_instruction[20:16] == D_instruction[25:21])   //rt == rs
                        hazard_D_EX = 1;
                    else if (EX_instruction[20:16] == D_instruction[20:16]) //rt == rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end
            
                else if ( D_instruction[31:26] == 6'h4 || D_instruction[31:26] == 6'h5) //bne and beq, phai rieng vi can ca 2
                begin
                    if (EX_instruction[20:16] == D_instruction[25:21] || EX_instruction[20:16] == D_instruction[20:16])   //EX.rt == D.rs or EX.rt == D.rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end
                
                else
                    hazard_D_EX = 0;
            end

            else if (!EX_instruction[31:26] || EX_instruction[31:26] == 6'h1c)     //lenh trong EX la lenh R)
            begin
                /* boi vi da co forward tu MEM ve EX
                if      (!D_instruction[31:26] || D_instruction[31:26] == 6'h1c) //R
                begin
                    if (EX_instruction[15:11] == D_instruction[25:21] || EX_instruction[15:11] == D_instruction[20:16]) //rd == rs rd == rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;

                end
                
                else if (D_instruction[31:28] == 4'b1000 || D_instruction[31:26] == 6'b001000) //load and addi 
                begin
                    if (EX_instruction[15:11] == D_instruction[25:21])   //rd == rs
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end

                else if ( D_instruction[31:28]==4'b1010) //store, may word or half word
                begin
                    //sw rt -> offset(rs)
                    if      (EX_instruction[15:11] == D_instruction[25:21])   //rd == rs
                        hazard_D_EX = 1;
                    else if (EX_instruction[15:11] == D_instruction[20:16]) //rd == rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end
                */

                if ( D_instruction[31:26] == 6'h4 || D_instruction[31:26] == 6'h5) //bne and beq, phai rieng vi can ca 2
                begin
                    if (EX_instruction[15:11] == D_instruction[25:21] || EX_instruction[15:11] == D_instruction[20:16])   //EX.rd == D.rs or EX.rd == D.rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end

                else
                    hazard_D_EX = 0;
            end

            else if (EX_instruction[31:26] == 6'b001000) //neu lenh trong EX la addi
            begin
                /* boi vi da co forward tu MEM ve EX
                if      (!D_instruction[31:26] || D_instruction[31:26] == 6'h1c) //R
                begin
                    if (EX_instruction[20:16] == D_instruction[25:21] || EX_instruction[20:16] == D_instruction[20:16]) //rt == rs rt == rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;

                end

                else if (D_instruction[31:28]==4'b1010) //store, may word or half word
                begin
                    //sw rt -> offset(rs)
                    if      (EX_instruction[20:16] == D_instruction[25:21])   //rt == rs
                        hazard_D_EX = 1;
                    else if (EX_instruction[20:16] == D_instruction[20:16]) //rt == rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end

                else if (D_instruction[31:28] == 4'b1000 || D_instruction[31:26] == 6'b001000) //load and addi
                begin
                    if (EX_instruction[20:16] == D_instruction[25:21])   //rt == rs
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end
                */

                if ( D_instruction[31:26] == 6'h4 || D_instruction[31:26] == 6'h5) //bne and beq, phai rieng vi can ca 2
                begin
                    if (EX_instruction[20:16] == D_instruction[25:21] || EX_instruction[20:16] == D_instruction[20:16])   //EX.rt == D.rs or EX.rt == D.rt
                        hazard_D_EX = 1;
                    else
                        hazard_D_EX = 0;
                end
                
                else
                    hazard_D_EX = 0;
            end
            else
                hazard_D_EX = 0;

            if (!MEM_instruction)
                hazard_D_MEM = 0;
            else if (MEM_instruction[31:28] == 4'b1000)   //neu lenh truoc la load, cho 1 stage
            begin
                if      (!D_instruction[31:26] ||  D_instruction[31:26] == 6'h1c) //R
                begin
                    if (MEM_instruction[20:16] == D_instruction[25:21] || MEM_instruction[20:16] == D_instruction[20:16]) //rt == rs rt == rt
                        hazard_D_MEM = 1;
                    else
                        hazard_D_MEM = 0;
                end
                
                else if (D_instruction[31:28] == 4'b1000 || D_instruction[31:26] == 6'b001000 ) //load and addi
                begin
                    if (MEM_instruction[20:16] == D_instruction[25:21])   //rt == rs
                        hazard_D_MEM = 1;
                    else
                        hazard_D_MEM = 0;
                end

                else if ( D_instruction[31:28]==4'b1010) //store, may word or half word
                begin
                    //sw rt -> offset(rs)
                    if      (MEM_instruction[20:16] == D_instruction[25:21])   //rt == rs
                        hazard_D_MEM = 1;
                    else if (MEM_instruction[20:16] == D_instruction[20:16]) //rt == rt
                        hazard_D_MEM = 1;
                    else
                        hazard_D_MEM = 0;
                end

                else if ( D_instruction[31:26] == 6'h4 || D_instruction[31:26] == 6'h5) //bne and beq, phai rieng vi can ca 2
                begin
                    if (MEM_instruction[20:16] == D_instruction[25:21] || MEM_instruction[20:16] == D_instruction[20:16])   //EX.rt == D.rs or EX.rt == D.rt
                        hazard_D_MEM = 1;
                    else
                        hazard_D_MEM = 0;
                end
                
                else
                    hazard_D_MEM = 0;
            end
            else
                hazard_D_MEM = 0;
        end

        D_stall = hazard_D_MEM || hazard_D_EX;  //chỉ cần có một sự phụ thuộc thì stall
    end
endmodule

module forward_detection(
    input       [31:0] MEM_instruction,
    input       [31:0] D_instruction,
    input       [31:0] EX_instruction,

    output reg  [1:0]  MEM_to_EX_forwardSignal,
    output reg  [1:0]  MEM_to_D_forwardSignal
);
    always @(MEM_instruction, D_instruction)
    begin
        MEM_to_D_forwardSignal = 2'b00; //prevent latch
        if (!MEM_instruction || !D_instruction) //nothing
            MEM_to_D_forwardSignal = 2'b00;

        else if (!MEM_instruction[31:26] || MEM_instruction[31:26] == 6'h1c)     //lenh trong MEM la lenh R)
        begin
            if      (!D_instruction[31:26] || D_instruction[31:26] == 6'h1c || D_instruction[31:26] == 6'h4 || D_instruction[31:26] == 6'h5) //R, bne and beq
            begin
                if (MEM_instruction[15:11] ==D_instruction[25:21]) //rd == rs
                    MEM_to_D_forwardSignal[1] = 1'b1;
                else
                    MEM_to_D_forwardSignal[1] = 1'b0;

                if (MEM_instruction[15:11] == D_instruction[20:16]) //rd == rt
                    MEM_to_D_forwardSignal[0] = 1'b1;
                else
                    MEM_to_D_forwardSignal[0] = 1'b0;                   //khong forward
            end
            
            else if (D_instruction[31:28] == 4'b1000 || D_instruction[31:26] == 6'b001000) //load and addi
            begin
                MEM_to_D_forwardSignal[0] = 0;
                if (MEM_instruction[15:11] == D_instruction[25:21])   //rd == rs
                    MEM_to_D_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_D_forwardSignal[1] = 1'b0;
            end

            else if (D_instruction[31:28]==4'b1010) //store in Decode stage
            begin //sw rt -> offset(rs)
                if (MEM_instruction[15:11] == D_instruction[25:21])   //rd == rs
                    MEM_to_D_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_D_forwardSignal[1] = 1'b0;
                
                if (MEM_instruction[15:11] == D_instruction[20:16])   //rd == rt
                    MEM_to_D_forwardSignal[0] = 1'b1;                      
                else
                    MEM_to_D_forwardSignal[0] = 1'b0;
            end

            else
                MEM_to_D_forwardSignal = 2'b00;
        end
    
        else if (MEM_instruction[31:26] == 6'b001000) //neu lenh trong MEM la addi
        begin
            if      (!D_instruction[31:26] || D_instruction[31:26] == 6'h1c || D_instruction[31:26] == 6'h4 || D_instruction[31:26] == 6'h5) //R, bne and beq
            begin
                if (MEM_instruction[20:16] == D_instruction[25:21]) //rt == rs
                    MEM_to_D_forwardSignal[1] = 1'b1;
                else
                    MEM_to_D_forwardSignal[1] = 1'b0;

                if (MEM_instruction[20:16] == D_instruction[20:16]) //rt == rt
                    MEM_to_D_forwardSignal[0] = 1'b1;
                else
                    MEM_to_D_forwardSignal[0] = 1'b0;
            end
            
            else if (D_instruction[31:28]==4'b1010) //store in Decode stage
            begin //sw rt -> offset(rs)
                if (MEM_instruction[20:16] == D_instruction[25:21])   //rt == rs
                    MEM_to_D_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_D_forwardSignal[1] = 1'b0;
                
                if (MEM_instruction[20:16] == D_instruction[20:16])   //rt == rt
                    MEM_to_D_forwardSignal[0] = 1'b1;                      
                else
                    MEM_to_D_forwardSignal[0] = 1'b0;
            end

            else if (D_instruction[31:28] == 4'b1000 || D_instruction[31:26] == 6'b001000 ) //load and addi
            begin
                MEM_to_D_forwardSignal[0] = 0;
                if      (MEM_instruction[20:16] == D_instruction[25:21])   //rd == rs
                    MEM_to_D_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_D_forwardSignal[1] = 1'b0;
            end
            
            else
                MEM_to_D_forwardSignal = 2'b00;   //nothing
        end

        else
            MEM_to_D_forwardSignal = 2'b00;
    end

    always @(MEM_instruction, EX_instruction)
    begin
        MEM_to_EX_forwardSignal = 2'b00; //prevent latch
        if (!MEM_instruction || !EX_instruction) //nothing
            MEM_to_EX_forwardSignal = 2'b00;

        else if (!MEM_instruction[31:26] || MEM_instruction[31:26] == 6'h1c)     //lenh trong MEM la lenh R)
        begin
            if      (!EX_instruction[31:26] || EX_instruction[31:26] == 6'h1c || EX_instruction[31:26] == 6'h4 || EX_instruction[31:26] == 6'h5) //R, bne and beq, mul
            begin
                if (MEM_instruction[15:11] ==EX_instruction[25:21]) //rd == rs
                    MEM_to_EX_forwardSignal[1] = 1'b1;
                else
                    MEM_to_EX_forwardSignal[1] = 1'b0;

                if (MEM_instruction[15:11] == EX_instruction[20:16]) //rd == rt
                    MEM_to_EX_forwardSignal[0] = 1'b1;
                else
                    MEM_to_EX_forwardSignal[0] = 1'b0;                   //khong forward
            end
            
            else if (EX_instruction[31:28] == 4'b1000 || EX_instruction[31:26] == 6'b001000) //load and addi
            begin
                MEM_to_EX_forwardSignal[0] = 0;
                if (MEM_instruction[15:11] == EX_instruction[25:21])   //rd == rs
                    MEM_to_EX_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_EX_forwardSignal[1] = 1'b0;
            end

            else if (EX_instruction[31:28]==4'b1010) //store in EX stage
            begin //sw rt -> offset(rs)
                if (MEM_instruction[15:11] == EX_instruction[25:21])   //rd == rs
                    MEM_to_EX_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_EX_forwardSignal[1] = 1'b0;
                
                if (MEM_instruction[15:11] == EX_instruction[20:16])   //rd == rt
                    MEM_to_EX_forwardSignal[0] = 1'b1;                      
                else
                    MEM_to_EX_forwardSignal[0] = 1'b0;
            end

            else
                MEM_to_EX_forwardSignal = 2'b00;
        end
    
        else if (MEM_instruction[31:26] == 6'b001000) //neu lenh trong MEM la addi
        begin
            if      (!EX_instruction[31:26] || EX_instruction[31:26] == 6'h1c || EX_instruction[31:26] == 6'h4 || EX_instruction[31:26] == 6'h5) //R, bne and beq, mul
            begin
                if (MEM_instruction[20:16] == EX_instruction[25:21]) //rt == rs
                    MEM_to_EX_forwardSignal[1] = 1'b1;
                else
                    MEM_to_EX_forwardSignal[1] = 1'b0;

                if (MEM_instruction[20:16] == EX_instruction[20:16]) //rt == rt
                    MEM_to_EX_forwardSignal[0] = 1'b1;
                else
                    MEM_to_EX_forwardSignal[0] = 1'b0;
            end
            
            else if (EX_instruction[31:28]==4'b1010) //store in EXecode stage
            begin //sw rt -> offset(rs)
                if (MEM_instruction[20:16] == EX_instruction[25:21])   //rt == rs
                    MEM_to_EX_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_EX_forwardSignal[1] = 1'b0;
                
                if (MEM_instruction[20:16] == EX_instruction[20:16])   //rt == rt
                    MEM_to_EX_forwardSignal[0] = 1'b1;                      
                else
                    MEM_to_EX_forwardSignal[0] = 1'b0;
            end

            else if (EX_instruction[31:28] == 4'b1000 || EX_instruction[31:26] == 6'b001000 ) //load and addi
            begin
                MEM_to_EX_forwardSignal[0] = 0;
                if      (MEM_instruction[20:16] == EX_instruction[25:21])   //rd == rs
                    MEM_to_EX_forwardSignal[1] = 1'b1;                      
                else
                    MEM_to_EX_forwardSignal[1] = 1'b0;
            end
            
            else
                MEM_to_EX_forwardSignal = 2'b00;   //nothing
        end

        else
            MEM_to_EX_forwardSignal = 2'b00;
    end
endmodule