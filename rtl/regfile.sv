/*
 * regfile.sv
 *
 *  Created on: 2020-04-29 20:16
 *      Author: Jack Chen <redchenjs@live.com>
 */

`include "config.sv"

module regfile(
    input logic clk_i,
    input logic rst_n_i,

    input logic [3:0] reg_rd_addr_i,

    input logic        reg_wr_en_i,
    input logic  [2:0] reg_wr_addr_i,
    input logic [63:0] reg_wr_data_i,

    output logic [7:0] reg_rd_data_o,

    output logic [31:0] reg_gate_time_o
);

logic [7:0] regs[11:0];
logic [7:0] data[15:0];

genvar i;
generate
    assign data[0] = 8'h00;
    assign data[1] = {RTL_REVISION_MAJOR, RTL_REVISION_MINOR};
    assign data[2] = 8'h00;
    assign data[3] = 8'h00;

    for (i = 0; i < 12; i++) begin: rd_data
        assign data[i + 4] = regs[i];
    end

    assign reg_gate_time_o = {data[7], data[6], data[5], data[4]};
endgenerate

assign reg_rd_data_o = data[reg_rd_addr_i];

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        regs[0] <= DEFAULT_GATE_TIME[7:0];
        regs[1] <= DEFAULT_GATE_TIME[15:8];
        regs[2] <= DEFAULT_GATE_TIME[23:16];
        regs[3] <= DEFAULT_GATE_TIME[31:24];

        for (integer i = 4; i < 12; i++) begin
            regs[i] <= 8'h00;
        end
    end else begin
        if (reg_wr_en_i) begin
            if (reg_wr_addr_i[2]) begin
                {regs[7], regs[6], regs[5], regs[4]} <= reg_wr_data_i[31:0];
                {regs[11], regs[10], regs[9], regs[8]} <= reg_wr_data_i[63:32];
            end else begin
                regs[reg_wr_addr_i[1:0]] <= reg_wr_data_i[7:0];
            end
        end
    end
end

endmodule
