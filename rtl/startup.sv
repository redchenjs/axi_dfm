/*
 * startup.sv
 *
 *  Created on: 2021-06-21 12:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

`include "config.sv"

module startup(
    input logic clk_i,
    input logic rst_n_i,

    input logic [4:0] gate_sync_i,

    output logic [4:0] gate_en_o
);

logic        gate_sl;
logic  [4:0] gate_en;
logic [31:0] gate_cnt;

assign gate_en_o = gate_en;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_sl  <= 1'b0;
        gate_en  <= 5'b00000;
        gate_cnt <= 32'h0000_0000;
    end else begin
        if (gate_en == gate_sync_i) begin
            gate_sl  <= (gate_en != 5'b01111);
            gate_en  <= (gate_cnt == DEFAULT_GATE_TIME_SHIFT) ? {gate_en[3:0], gate_sl} : gate_en;
            gate_cnt <= (gate_cnt == DEFAULT_GATE_TIME_SHIFT) ? 32'h0000_0000 : gate_cnt + 1'b1;
        end
    end
end

endmodule
