/*
 * control.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

module control(
    input logic clk_i,
    input logic rst_n_i,

    input logic dc_i,

    input logic       spi_byte_vld_i,
    input logic [7:0] spi_byte_data_i,

    output logic       reg_wr_en_o,
    output logic [1:0] reg_wr_addr_o,

    output logic       reg_rd_en_o,
    output logic [4:0] reg_rd_addr_o
);

typedef enum logic [7:0] {
    CONF_WR = 8'h2a,
    INFO_RD = 8'h3a,
    DATA_RD = 8'h3b
} cmd_t;

logic gate_en;
logic conf_wr;

logic info_rd;
logic data_rd;

logic [1:0] wr_addr;
logic [4:0] rd_addr;

wire conf_done = (wr_addr == 2'h3);

wire info_done = (rd_addr == 5'h06);
wire data_done = (rd_addr == 5'h12);

assign reg_wr_en_o   = conf_wr & spi_byte_vld_i;
assign reg_wr_addr_o = wr_addr;

assign reg_rd_en_o   = data_rd;
assign reg_rd_addr_o = rd_addr;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        conf_wr <= 1'b0;

        info_rd <= 1'b0;
        data_rd <= 1'b0;

        wr_addr <= 2'h0;
        rd_addr <= 5'h00;
    end else begin
        if (spi_byte_vld_i) begin
            if (!dc_i) begin  // Command
                wr_addr <= 2'h0;

                case (spi_byte_data_i)
                    CONF_WR: begin
                        conf_wr <= 1'b1;

                        info_rd <= 1'b0;
                        data_rd <= 1'b0;

                        rd_addr <= 5'h00;
                    end
                    INFO_RD: begin
                        conf_wr <= 1'b0;

                        info_rd <= 1'b1;
                        data_rd <= 1'b0;

                        rd_addr <= 5'h00;
                    end
                    DATA_RD: begin
                        conf_wr <= 1'b0;

                        info_rd <= 1'b0;
                        data_rd <= 1'b1;

                        rd_addr <= 5'h08;
                    end
                    default: begin
                        conf_wr <= 1'b0;

                        info_rd <= 1'b0;
                        data_rd <= 1'b0;

                        rd_addr <= 5'h00;
                    end
                endcase
            end else begin    // Data
                conf_wr <= conf_done ? 1'b0 : conf_wr;

                info_rd <= info_done ? 1'b0 : info_rd;
                data_rd <= data_done ? 1'b0 : data_rd;

                wr_addr <= conf_wr ? wr_addr + 1'b1 : 2'h0;
                rd_addr <= (info_rd | data_rd) ? rd_addr + 1'b1 : 5'h00;
            end
        end
    end
end

endmodule
