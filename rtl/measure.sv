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

logic sig_rst_n;

logic gate_real;
logic gate_real_n;

logic sig_gate;
logic sig_gate_n;

logic [3:0] ref_gate;
logic [3:0] ref_gate_n;

logic        gate_en;
logic [31:0] gate_cnt;

logic [31:0] sig_clk_cnt;
logic [31:0] sig_clk_out;

logic [31:0] ref_clk_cnt[4];
logic [31:0] ref_clk_out[4];

logic [31:0] sig_clk_sum;
logic [31:0] ref_clk_sum;

logic  [3:0] reg_wr_en;
logic [63:0] reg_wr_data;

assign reg_wr_en_o   = reg_wr_en[3];
assign reg_wr_data_o = reg_wr_data;

rst_syn sig_rst_syn(
    .clk_i(sig_clk_i),
    .rst_n_i(rst_n_i),
    .rst_n_o(sig_rst_n)
);

data_syn sig_gate_syn(
    .clk_i(sig_clk_i),
    .rst_n_i(sig_rst_n),
    .data_i(gate_en),
    .data_o(sig_gate)
);

edge2en sig_gate_en(
    .clk_i(sig_clk_i),
    .rst_n_i(sig_rst_n),
    .data_i(sig_gate),
    .neg_edge_o(sig_gate_n)
);

data_syn gate_real_syn(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_gate),
    .data_o(gate_real)
);

edge2en gate_real_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(gate_real),
    .neg_edge_o(gate_real_n)
);

always_ff @(posedge sig_clk_i or negedge sig_rst_n)
begin
    if (!sig_rst_n) begin
        sig_clk_cnt <= 32'h0000_0000;
        sig_clk_out <= 32'h0000_0000;
    end else begin
        sig_clk_cnt <= sig_gate_n ? 32'h0000_0000 : (sig_gate ? sig_clk_cnt + 1'b1 : sig_clk_cnt);
        sig_clk_out <= sig_gate_n ? sig_clk_cnt : sig_clk_out;
    end
end

genvar i;
generate
    for (i = 0; i < 4; i++) begin: measure_block
        data_syn ref_gate_syn(
            .clk_i(ref_clk_i[i]),
            .rst_n_i(ref_rst_n_i[i]),
            .data_i(sig_gate),
            .data_o(ref_gate[i])
        );

        edge2en ref_gate_en(
            .clk_i(ref_clk_i[i]),
            .rst_n_i(ref_rst_n_i[i]),
            .data_i(ref_gate[i]),
            .neg_edge_o(ref_gate_n[i])
        );

        always_ff @(posedge ref_clk_i[i] or negedge ref_rst_n_i[i])
        begin
            if (!ref_rst_n_i[i]) begin
                ref_clk_cnt[i] <= 32'h0000_0000;
                ref_clk_out[i] <= 32'h0000_0000;
            end else begin
                ref_clk_cnt[i] <= ref_gate_n[i] ? 32'h0000_0000 : (ref_gate[i] ? ref_clk_cnt[i] + 1'b1 : ref_clk_cnt[i]);
                ref_clk_out[i] <= ref_gate_n[i] ? ref_clk_cnt[i] : ref_clk_out[i];
            end
        end
    end
endgenerate

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        gate_en  <= 1'b0;
        gate_cnt <= 32'h0000_0000;

        sig_clk_sum <= 32'h0000_0000;
        ref_clk_sum <= 32'h0000_0000;

        reg_wr_en   <= 4'h0;
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        gate_en  <= gate_real ? ((gate_cnt == DEFAULT_GATE_TIME) ? 1'b0 : gate_en) : 1'b1;
        gate_cnt <= gate_real & gate_en & (gate_cnt != DEFAULT_GATE_TIME) ? gate_cnt + 1'b1 : 32'h0000_0000;

        sig_clk_sum <= reg_wr_en[0] ? sig_clk_cnt : sig_clk_sum;
        ref_clk_sum <= reg_wr_en[0] ? ref_clk_out[0] + ref_clk_out[1] :
                       reg_wr_en[1] ? ref_clk_out[2] + ref_clk_out[3] + ref_clk_sum :
                       ref_clk_sum;

        reg_wr_en   <= {reg_wr_en[2:0], gate_real_n};
        reg_wr_data <= reg_wr_en[2] ? {ref_clk_sum, sig_clk_sum} : reg_wr_data;
    end
end

endmodule
