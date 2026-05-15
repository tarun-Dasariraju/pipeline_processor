`timescale 1ns / 1ps
///pineline processor design
module ppd(
    input clk,
    input reset
);
reg [7:0] regfile [0:7];
reg [15:0] instr_mem [0:15];
reg [7:0] data_mem [0:15];
reg [3:0] pc;
reg [15:0] if_id_instr;
reg [3:0] id_ex_opcode;
reg [3:0] id_ex_rd;
reg [7:0] id_ex_data1;
reg [7:0] id_ex_data2;
reg [3:0] ex_wb_rd;
reg [7:0] ex_wb_result;
integer i;
parameter ADD  = 4'b0001;
parameter SUB  = 4'b0010;
parameter LOAD = 4'b0011;
initial begin
    regfile[0] = 8'd0;
    regfile[1] = 8'd10;
    regfile[2] = 8'd5;
    regfile[3] = 8'd2;
    regfile[4] = 8'd8;
    regfile[5] = 8'd4;
    regfile[6] = 8'd0;
    regfile[7] = 8'd0;
    data_mem[0] = 8'd25;
    data_mem[1] = 8'd50;
    instr_mem[0] = {ADD, 4'd0, 4'd1, 4'd2};
    instr_mem[1] = {SUB, 4'd3, 4'd4, 4'd5};
    instr_mem[2] = {LOAD, 4'd6, 4'd0, 4'd1};
end
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        pc <= 0;
        if_id_instr <= 0;
        id_ex_opcode <= 0;
        id_ex_rd <= 0;
        id_ex_data1 <= 0;
        id_ex_data2 <= 0;
        ex_wb_rd <= 0;
        ex_wb_result <= 0;
    end
    else
    begin
        regfile[ex_wb_rd] <= ex_wb_result;
        case(id_ex_opcode)
            ADD:
            begin
                ex_wb_result <= id_ex_data1 + id_ex_data2;
                ex_wb_rd <= id_ex_rd;
            end
            SUB:
            begin
                ex_wb_result <= id_ex_data1 - id_ex_data2;
                ex_wb_rd <= id_ex_rd;
            end
            LOAD:
            begin
                ex_wb_result <= data_mem[id_ex_data2];
                ex_wb_rd <= id_ex_rd;
            end
            default:
            begin
                ex_wb_result <= 0;
                ex_wb_rd <= 0;
            end
        endcase
        id_ex_opcode <= if_id_instr[15:12];
        id_ex_rd     <= if_id_instr[11:8];
        id_ex_data1  <= regfile[if_id_instr[7:4]];
        id_ex_data2  <= if_id_instr[3:0];
        if_id_instr <= instr_mem[pc];
        pc <= pc + 1;
    end
end
endmodule
