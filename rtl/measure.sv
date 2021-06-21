/*
 * measure.sv
 *
 *  Created on: 2021-06-21 14:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`include "config.sv"

module measure(
    input logic clk_i,
    input logic rst_n_i,

    input logic sig_clk_i,

    input logic gate_en_i,

    output logic        reg_wr_en_o,
    output logic [63:0] reg_wr_data_o,

    output logic gate_sync_o
);

logic sig_clk_s;
logic sig_clk_p;

logic gate_sync;
logic gate_sync_n;

logic        gate_en;
logic [31:0] gate_cnt;

logic [31:0] sig_clk_cnt;
logic [31:0] ref_clk_cnt;

logic        reg_wr_en;
logic [63:0] reg_wr_data;

assign reg_wr_en_o   = reg_wr_en;
assign reg_wr_data_o = reg_wr_data;

assign gate_sync_o = gate_sync;

data_syn sig_clk_syn(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_clk_i),
    .data_o(sig_clk_s)
);

edge2en sig_clk_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_clk_s),
    .pos_edge_o(sig_clk_p)
);

edge2en gate_sync_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(gate_sync),
    .neg_edge_o(gate_sync_n)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_en  <= 1'b0;
        gate_cnt <= 32'h0000_0000;

        gate_sync <= 1'b0;

        sig_clk_cnt <= 32'h0000_0000;
        ref_clk_cnt <= 32'h0000_0000;

        reg_wr_en   <= 1'b0;
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        gate_en  <= gate_sync ? ((gate_cnt == DEFAULT_GATE_TIME_TOTAL) ? 1'b0 : gate_en) : gate_en_i;
        gate_cnt <= gate_en & gate_sync & (gate_cnt != DEFAULT_GATE_TIME_TOTAL) ? gate_cnt + 1'b1 : 32'h0000_0000;

        if (gate_sync) begin
            gate_sync <= sig_clk_p & ~gate_en ? 1'b0 : gate_sync;

            sig_clk_cnt <= sig_clk_p ? sig_clk_cnt + 1'b1 : sig_clk_cnt;
            ref_clk_cnt <= ref_clk_cnt + 1'b1;
        end else begin
            gate_sync <= sig_clk_p & gate_en ? 1'b1 : gate_sync;

            sig_clk_cnt <= reg_wr_en ? 32'h0000_0000 : sig_clk_cnt;
            ref_clk_cnt <= reg_wr_en ? 32'h0000_0000 : ref_clk_cnt;
        end

        reg_wr_en   <= gate_sync_n;
        reg_wr_data <= gate_sync_n ? {ref_clk_cnt, sig_clk_cnt} : reg_wr_data;
    end
end

endmodule
