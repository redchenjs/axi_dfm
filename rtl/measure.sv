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

    input logic        gate_en_i,
    input logic [31:0] gate_time_i,

    output logic        reg_wr_en_o,
    output logic [95:0] reg_wr_data_o
);

logic sig_sync;
logic gate_sync_n;

logic gate_done;

logic sig_clk_p;
logic sig_clk_n;

logic        gate_en;
logic [31:0] gate_cnt;

logic [31:0] sig_cnt;
logic [31:0] clk_cnt;

logic        reg_wr_en;
logic [95:0] reg_wr_data;

assign reg_wr_en_o   = reg_wr_en;
assign reg_wr_data_o = reg_wr_data;

edge2en sig_sync_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_sync),
    .neg_edge_o(gate_sync_n)
);

edge2en sig_clk_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_clk_i),
    .pos_edge_o(sig_clk_p),
    .neg_edge_o(sig_clk_n)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_en  <= 1'b0;
        gate_cnt <= 32'h0000_0000;

        sig_sync <= 1'b0;
    end else begin
        gate_en  <= sig_sync ? ((gate_cnt == gate_time_i) ? 1'b0 : gate_en) : 1'b1;
        gate_cnt <= gate_en & sig_sync & (gate_cnt != gate_time_i) ? gate_cnt + 1'b1 : 32'h0000_0000;

        if (sig_sync) begin
            sig_sync <= sig_clk_p & ~gate_en ? 1'b0 : sig_sync;
        end else begin
            sig_sync <= sig_clk_p & gate_en ? 1'b1 : sig_sync;
        end
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_done <= 1'b0;

        sig_cnt <= 32'h0000_0000;
        clk_cnt <= 32'h0000_0000;

        reg_wr_en   <= 1'b0;
        reg_wr_data <= 96'h0000_0000_0000_0000_0000_0000;
    end else begin
        gate_done <= ~gate_sync_n;

        if (!gate_done) begin
            sig_cnt <= 32'h0000_0000;
            clk_cnt <= 32'h0000_0000;
        end else if (sig_sync) begin
            sig_cnt <= sig_clk_p ? sig_cnt + 1'b1 : sig_cnt;
            clk_cnt <= clk_cnt + 1'b1;
        end

        reg_wr_en   <= gate_sync_n;
        reg_wr_data <= gate_sync_n ? {clk_cnt, sig_cnt} : reg_wr_data;
    end
end

endmodule
