/*
 * startup.sv
 *
 *  Created on: 2021-06-21 12:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module startup(
    input logic clk_i,
    input logic rst_n_i,

    input logic  [4:0] gate_sync_i,
    input logic [31:0] gate_shift_i,

    output logic [4:0] gate_en_o
);

logic  [4:0] gate_en;
logic [31:0] gate_cnt;
logic        gate_next;
logic        gate_done;

assign gate_en_o = gate_en;

edge2en gate_next_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(gate_done & (gate_en == gate_sync_i)),
    .pos_edge_o(gate_next)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_en   <= 5'b00000;
        gate_cnt  <= 32'h0000_0000;
        gate_done <= 1'b0;
    end else begin
        gate_en   <= gate_next ? {gate_en[3:0], (gate_sync_i != 5'b01111)} : gate_en;
        gate_cnt  <= gate_next ? 32'h0000_0000 : gate_cnt + 1'b1;
        gate_done <= gate_next ? 1'b0 : (gate_cnt == gate_shift_i) ? 1'b1 : gate_done;
    end
end

endmodule
