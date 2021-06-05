/*
 * sys_ctl.sv
 *
 *  Created on: 2020-05-07 09:58
 *      Author: Jack Chen <redchenjs@live.com>
 */

module sys_ctl(
    input logic clk_i,
    input logic rst_n_i,

    output logic sys_clk_o,
    output logic sys_rst_n_o,

    output logic [5:0] aux_clk_o,
    output logic [5:0] aux_rst_n_o
 );

 pll pll(
    .clk_in1(clk_i),
    .reset(~rst_n_i),
    .locked(pll_locked),
    .clk_out1(sys_clk_o),
    .clk_out2(aux_clk_o[0]),
    .clk_out3(aux_clk_o[1]),
    .clk_out4(aux_clk_o[2]),
    .clk_out5(aux_clk_o[3]),
    .clk_out6(aux_clk_o[4]),
    .clk_out7(aux_clk_o[5])
);

rst_syn sys_rst_n_syn(
    .clk_i(sys_clk_o),
    .rst_n_i(rst_n_i & pll_locked),
    .rst_n_o(sys_rst_n_o)
);

genvar i;
generate
    for (i = 0; i < 6; i++) begin: rd_data
        rst_syn aux_rst_n_syn(
            .clk_i(aux_clk_o[i]),
            .rst_n_i(rst_n_i & pll_locked),
            .rst_n_o(aux_rst_n_o[i])
        );
    end
endgenerate

endmodule
