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

    output logic       reg_rd_en_o,
    output logic [3:0] reg_rd_addr_o
);

typedef enum logic [7:0] {
    CONF_RD = 8'h3a,
    DATA_RD = 8'h3b
} cmd_t;

logic conf_rd;
logic data_rd;

logic [3:0] rd_addr;

assign reg_rd_en_o   = data_rd;
assign reg_rd_addr_o = rd_addr;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        conf_rd <= 1'b0;
        data_rd <= 1'b0;

        rd_addr <= 4'h0;
    end else begin
        if (spi_byte_vld_i) begin
            if (!dc_i) begin  // Command
                case (spi_byte_data_i)
                    CONF_RD: begin
                        conf_rd <= 1'b1;
                        data_rd <= 1'b0;

                        rd_addr <= 4'h0;
                    end
                    DATA_RD: begin
                        conf_rd <= 1'b0;
                        data_rd <= 1'b1;

                        rd_addr <= 4'h8;
                    end
                    default: begin
                        conf_rd <= 1'b0;
                        data_rd <= 1'b0;

                        rd_addr <= 4'h0;
                    end
                endcase
            end else begin    // Data
                conf_rd <= conf_rd & (rd_addr == 4'h6) ? 1'b0 : conf_rd;
                data_rd <= data_rd & (rd_addr == 4'he) ? 1'b0 : data_rd;

                rd_addr <= (conf_rd | data_rd) ? rd_addr + 1'b1 : 4'h0;
            end
        end
    end
end

endmodule
