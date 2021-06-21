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
    output logic sys_rst_n_o
 );

 pll pll(
    .clk_in1(clk_i),
    .reset(~rst_n_i),
    .locked(pll_locked),
    .clk_out1(sys_clk_o)
);

rst_syn sys_rst_n_syn(
    .clk_i(sys_clk_o),
    .rst_n_i(rst_n_i & pll_locked),
    .rst_n_o(sys_rst_n_o)
);

endmodule
