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

    input logic [3:0] ref_clk_i,
    input logic [3:0] ref_rst_n_i,

    output logic        reg_wr_en_o,
    output logic [63:0] reg_wr_data_o
);

logic [3:0] sig_clk_p;

logic        gate_en;
logic [31:0] gate_cnt;

logic [3:0] gate_sync;
logic [3:0] gate_sync_n;

logic       gate_sync_rst;
logic [3:0] gate_sync_done;
logic       gate_sync_done_p;

logic [31:0] sig_clk_cnt[4];
logic [31:0] ref_clk_cnt[4];

logic [31:0] sig_clk_out[4];
logic [31:0] ref_clk_out[4];

logic [31:0] sig_clk_sum;
logic [31:0] ref_clk_sum;

logic  [3:0] reg_wr_en;
logic [63:0] reg_wr_data;

assign reg_wr_en_o   = reg_wr_en[3];
assign reg_wr_data_o = reg_wr_data;

edge2en gate_sync_done_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(gate_sync_done == 4'hf),
    .pos_edge_o(gate_sync_done_p)
);

genvar i;
generate
    for (i = 0; i < 4; i++) begin: measure_block
        edge2en sig_clk_en(
            .clk_i(ref_clk_i[i]),
            .rst_n_i(ref_rst_n_i[i]),
            .data_i(sig_clk_i),
            .pos_edge_o(sig_clk_p[i])
        );

        edge2en gate_sync_en(
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),
            .data_i(gate_sync[i]),
            .neg_edge_o(gate_sync_n[i])
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

                    sig_clk_cnt[i] <= sig_clk_p[i] ? sig_clk_cnt[i] + 1'b1 : sig_clk_cnt[i];
                    ref_clk_cnt[i] <= ref_clk_cnt[i] + 1'b1;
                end else begin
                    gate_sync[i] <= sig_clk_p[i] & gate_en ? 1'b1 : gate_sync[i];

                    sig_clk_cnt[i] <= sig_clk_p[i] ? 32'h0000_0000 : sig_clk_cnt[i];
                    ref_clk_cnt[i] <= sig_clk_p[i] ? 32'h0000_0000 : ref_clk_cnt[i];
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

        gate_sync_rst  <= 1'b1;
        gate_sync_done <= 4'h0;

        for (integer i = 0; i < 4; i++) begin
            sig_clk_out[i] <= 32'h0000_0000;
            ref_clk_out[i] <= 32'h0000_0000;
        end

        sig_clk_sum <= 32'h0000_0000;
        ref_clk_sum <= 32'h0000_0000;

        reg_wr_en   <= 4'h0;
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        gate_en  <= gate_sync_rst ? 1'b1 : ((gate_cnt == DEFAULT_GATE_TIME) ? 1'b0 : gate_en);
        gate_cnt <= gate_sync_rst | ~gate_en | (gate_cnt == DEFAULT_GATE_TIME) ? 32'h0000_0000 : gate_cnt + 1'b1;

        gate_sync_rst <= reg_wr_en[3];

        for (integer i = 0; i < 4; i++) begin
            gate_sync_done[i] <= gate_sync_rst ? 1'b0 : (gate_sync_n[i] ? 1'b1 : gate_sync_done[i]);
        end

        for (integer i = 0; i < 4; i++) begin
            sig_clk_out[i] <= (gate_sync_done == 4'hf) ? sig_clk_cnt[i] : sig_clk_out[i];
            ref_clk_out[i] <= (gate_sync_done == 4'hf) ? ref_clk_cnt[i] : ref_clk_out[i];
        end

        sig_clk_sum <= reg_wr_en[0] ? sig_clk_out[0] + sig_clk_out[1] :
                       reg_wr_en[1] ? sig_clk_out[2] + sig_clk_out[3] + sig_clk_sum :
                       sig_clk_sum;

        ref_clk_sum <= reg_wr_en[0] ? ref_clk_out[0] + ref_clk_out[1] :
                       reg_wr_en[1] ? ref_clk_out[2] + ref_clk_out[3] + ref_clk_sum :
                       ref_clk_sum;

        reg_wr_en   <= {reg_wr_en[2:0], gate_sync_done_p};
        reg_wr_data <= reg_wr_en[2] ? {ref_clk_sum, sig_clk_sum} : reg_wr_data;
    end
end

endmodule
