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

    input logic       reg_rd_en_i,
    input logic [3:0] reg_rd_addr_i,

    input logic        reg_wr_en_i,
    input logic [63:0] reg_wr_data_i,

    output logic [7:0] reg_rd_data_o
);

logic [7:0] regs[7:0];
logic [7:0] data[15:0];

assign {data[3], data[2], data[1], data[0]} = DEFAULT_GATE_TIME_SHIFT;
assign {data[7], data[6], data[5], data[4]} = DEFAULT_GATE_TIME_TOTAL;

assign reg_rd_data_o = data[reg_rd_addr_i];

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        for (integer i = 0; i < 8; i++) begin
            regs[i]     <= 8'h00;
            data[i + 8] <= 8'h00;
        end
    end else begin
        if (reg_wr_en_i) begin
            {regs[7], regs[6], regs[5], regs[4], regs[3], regs[2], regs[1], regs[0]} <= reg_wr_data_i;
        end
        if (reg_rd_en_i) begin
            for (integer i = 0; i < 8; i++) begin
                data[i + 8] <= regs[i];
            end
        end
    end
end

endmodule
