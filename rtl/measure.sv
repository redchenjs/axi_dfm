/*
 * measure.sv
 *
 *  Created on: 2020-08-55 08:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

module measure(
    input logic clk_i,
    input logic rst_n_i,

    input logic sig_clk_i,

    input logic       gate_st_i,
    input logic [7:0] gate_time_i,

    output logic gate_sync_o,

    output logic        reg_wr_en_o,
    output logic [63:0] reg_wr_data_o
);

parameter [31:0] GATE_TIME = 10 * 1000 * 1000;

logic sig_clk_p;
logic sig_clk_n;

logic sig_sync_i;

logic sig_sync;
logic sig_rst_n;

logic [31:0] sync_cnt;

logic [31:0] sig_cnt;
logic [31:0] clk_cnt;

logic [63:0] reg_wr_data;

assign reg_wr_data_o = reg_wr_data;

assign gate_sync_o = sig_sync;

edge2en reg_wr_en_syn(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_sync),
    .neg_edge_o(reg_wr_en_o)
);

edge2en sig_clk_syn(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_clk_i),
    .pos_edge_o(sig_clk_p),
    .neg_edge_o(sig_clk_n)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        sig_sync_i <= 1'b0;
        sync_cnt <= 32'h0000_0000;
        sig_sync <= 1'b0;
    end else begin
        sig_sync_i <= gate_st_i ? 1'b1 : ((sync_cnt == GATE_TIME) ? 1'b0 : sig_sync_i);
        sync_cnt <= sig_sync_i & (sync_cnt != GATE_TIME) ? sync_cnt + 1'b1 : 32'h0000_0000;
        if (sig_sync) begin
            sig_sync <= sig_clk_p & ~sig_sync_i ? 1'b0 : sig_sync;
        end else begin
            sig_sync <= sig_clk_p & sig_sync_i ? 1'b1 : sig_sync;
        end
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        sig_cnt <= 32'h0000_0000;
        clk_cnt <= 32'h0000_0000;

        sig_rst_n <= 1'b0;
    end else begin
        if (!sig_rst_n) begin
            sig_cnt <= 32'h0000_0000;
            clk_cnt <= 32'h0000_0000;
        end else if (sig_sync) begin
            sig_cnt <= sig_clk_p ? sig_cnt + 1'b1 : sig_cnt;
            clk_cnt <= clk_cnt + 1'b1;
        end

        sig_rst_n <= ~reg_wr_en_o;
    end
end

always_ff @(posedge reg_wr_en_o or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        reg_wr_data <= {clk_cnt, sig_cnt};
    end
end

endmodule
