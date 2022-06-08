/*
 * axi_dfm_v1_0.sv
 *
 *  Created on: 2022-06-07 16:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module axi_dfm_v1_0(
    input logic s_axi_aclk,
    input logic s_axi_aresetn,

    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,

    input  logic [31:0] s_axi_wdata,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    output logic s_axi_bvalid,
    input  logic s_axi_bready,

    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,

    output logic [31:0] s_axi_rdata,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    input  logic signal_in,
    output logic signal_done
);

logic [4:0] gate_en;
logic [4:0] gate_sync;

logic [31:0] gate_shift;
logic [31:0] gate_total;

logic  [4:0] raw_wr_en;
logic [63:0] raw_wr_data[5];

logic        reg_wr_en;
logic [63:0] reg_wr_data;

logic [63:0] reg_rd_data;

assign s_axi_awready = s_axi_aresetn && s_axi_awvalid && (!s_axi_bvalid || s_axi_bready);
assign s_axi_wready  = s_axi_aresetn && s_axi_wvalid  && (!s_axi_bvalid || s_axi_bready);
assign s_axi_arready = s_axi_aresetn && s_axi_arvalid && (!s_axi_rvalid || s_axi_rready);

assign signal_done = reg_wr_en;

always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if (!s_axi_aresetn) begin
        gate_shift <= 32'h0000_0000;
        gate_total <= 32'h0000_0000;

        reg_rd_data <= 64'h0000_0000_0000_0000;

        s_axi_bvalid <= 1'b0;
        s_axi_rvalid <= 1'b0;

        s_axi_rdata <= 32'h0000_0000;
    end else begin
        if (s_axi_awready) begin
            case (s_axi_awaddr[7:0])
                8'h00:
                    gate_shift <= s_axi_wdata;
                8'h04:
                    gate_total <= s_axi_wdata;
                default:
                    reg_rd_data <= reg_wr_data;
            endcase
        end

        if (s_axi_arready) begin
            case (s_axi_araddr[7:0])
                8'h00:
                    s_axi_rdata <= gate_shift;
                8'h04:
                    s_axi_rdata <= gate_total;
                8'h08:
                    s_axi_rdata <= reg_rd_data[63:32];
                8'h0C:
                    s_axi_rdata <= reg_rd_data[31:0];
                default:
                    s_axi_rdata <= 32'h0000_0000;
            endcase
        end

        s_axi_bvalid <= (s_axi_bvalid & ~s_axi_bready) | s_axi_awready;
        s_axi_rvalid <= (s_axi_rvalid & ~s_axi_rready) | s_axi_arready;
    end
end

startup startup(
    .clk_i(s_axi_aclk),
    .rst_n_i(s_axi_aresetn),

    .gate_sync_i(gate_sync),
    .gate_shift_i(gate_shift),

    .gate_en_o(gate_en)
);

genvar i;
generate
    for (i = 0; i < 5; i++) begin: measure_block
        measure measure(
            .clk_i(s_axi_aclk),
            .rst_n_i(s_axi_aresetn),

            .sig_clk_i(signal_in),

            .gate_en_i(gate_en[i]),
            .gate_total_i(gate_total),

            .reg_wr_en_o(raw_wr_en[i]),
            .reg_wr_data_o(raw_wr_data[i]),

            .gate_sync_o(gate_sync[i])
        );
    end
endgenerate

always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if (!s_axi_aresetn) begin
        reg_wr_en   <= 1'b0;
        reg_wr_data <= 64'h0000_0000_0000_0000;
    end else begin
        reg_wr_en <= raw_wr_en[0] | raw_wr_en[1] | raw_wr_en[2] | raw_wr_en[3] | raw_wr_en[4];

        case (raw_wr_en)
            5'b00001:
                reg_wr_data <= raw_wr_data[0];
            5'b00010:
                reg_wr_data <= raw_wr_data[1];
            5'b00100:
                reg_wr_data <= raw_wr_data[2];
            5'b01000:
                reg_wr_data <= raw_wr_data[3];
            5'b10000:
                reg_wr_data <= raw_wr_data[4];
            default:
                reg_wr_data <= reg_wr_data;
        endcase
    end
end

endmodule
