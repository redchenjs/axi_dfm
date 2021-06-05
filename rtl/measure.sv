/*
 * measure.sv
 *
 *  Created on: 2020-08-55 08:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

`include "config.sv"

module measure(
    input logic clk_i,
    input logic rst_n_i,

    input logic sig_clk_i,

    input logic [5:0] ref_clk_i,
    input logic [5:0] ref_rst_n_i,

    output logic        reg_wr_en_o,
    output logic [63:0] reg_wr_data_o
);

logic clk_cnt_rst;

logic [5:0] sig_clk_p;

logic        gate_en;
logic [31:0] gate_cnt;

logic [5:0] gate_sync;
logic       gate_sync_n;

logic [31:0] sig_clk_cnt[6];
logic [31:0] ref_clk_cnt[6];

logic [63:0] reg_wr_data;

wire gate_sync_or = gate_sync[0] | gate_sync[1] | gate_sync[2] |
                    gate_sync[3] | gate_sync[4] | gate_sync[5];

wire [31:0] sig_clk_out = sig_clk_cnt[0] + sig_clk_cnt[1] + sig_clk_cnt[2] +
                          sig_clk_cnt[3] + sig_clk_cnt[4] + sig_clk_cnt[5];
wire [31:0] ref_clk_out = ref_clk_cnt[0] + ref_clk_cnt[1] + ref_clk_cnt[2] +
                          ref_clk_cnt[3] + ref_clk_cnt[4] + ref_clk_cnt[5];

assign reg_wr_en_o   = gate_sync_n;
assign reg_wr_data_o = reg_wr_data;

edge2en gate_sync_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(gate_sync_or),
    .neg_edge_o(gate_sync_n)
);

genvar i;
generate
    for (i = 0; i < 6; i++) begin: sig_clk
        edge2en sig_clk_en(
            .clk_i(ref_clk_i[i]),
            .rst_n_i(ref_rst_n_i[i]),
            .data_i(sig_clk_i),
            .pos_edge_o(sig_clk_p[i])
        );

        always_ff @(posedge ref_clk_i[i] or negedge ref_rst_n_i[i])
        begin
            if (!ref_rst_n_i[i]) begin
                gate_sync[i] <= 1'b0;

                sig_clk_cnt[i] <= 32'h0000_0000;
                ref_clk_cnt[i] <= 32'h0000_0000;
            end else begin
                if (gate_sync[i]) begin
                    gate_sync[i] <= sig_clk_p[i] & ~gate_en ? 1'b0 : gate_sync[i];
                end else begin
                    gate_sync[i] <= sig_clk_p[i] & gate_en ? 1'b1 : gate_sync[i];
                end

                if (clk_cnt_rst) begin
                    sig_clk_cnt[i] <= 32'h0000_0000;
                    ref_clk_cnt[i] <= 32'h0000_0000;
                end else if (gate_sync[i]) begin
                    sig_clk_cnt[i] <= sig_clk_p[i] ? sig_clk_cnt[i] + 1'b1 : sig_clk_cnt[i];
                    ref_clk_cnt[i] <= ref_clk_cnt[i] + 1'b1;
                end
            end
        end
    end
endgenerate

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_en  <= 1'b0;
        gate_cnt <= 32'h0000_0000;

        clk_cnt_rst <= 1'b0;

        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        gate_en  <= gate_sync_or ? ((gate_cnt == DEFAULT_GATE_TIME) ? 1'b0 : gate_en) : 1'b1;
        gate_cnt <= gate_en & gate_sync_or & (gate_cnt != DEFAULT_GATE_TIME) ? gate_cnt + 1'b1 : 32'h0000_0000;

        clk_cnt_rst <= gate_sync_n;

        reg_wr_data <= gate_sync_n ? {ref_clk_out, sig_clk_out} : reg_wr_data;
    end
end

endmodule
