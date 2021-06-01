create_clock -period 20.00 [get_ports spi_sclk_i]

set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets spi_sclk_i]

set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n_i]
set_property IOSTANDARD LVCMOS33 [get_ports dc_i]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk_i]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi_i]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs_n_i]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso_o]

set_property IOSTANDARD LVCMOS33 [get_ports sig_clk_i]
set_property IOSTANDARD LVCMOS33 [get_ports sig_sync_i]
set_property IOSTANDARD LVCMOS33 [get_ports gate_sync_o]

set_property PACKAGE_PIN L17 [get_ports clk_i]
set_property PACKAGE_PIN R3 [get_ports rst_n_i]
set_property PACKAGE_PIN T3 [get_ports dc_i]
set_property PACKAGE_PIN R2 [get_ports spi_sclk_i]
set_property PACKAGE_PIN T1 [get_ports spi_mosi_i]
set_property PACKAGE_PIN T2 [get_ports spi_cs_n_i]
set_property PACKAGE_PIN U1 [get_ports spi_miso_o]

set_property PACKAGE_PIN W2 [get_ports sig_clk_i]
set_property PACKAGE_PIN V2 [get_ports gate_sync_o]

set_false_path -from [get_ports rst_n_i]
set_false_path -from [get_ports dc_i]
set_false_path -from [get_ports spi_sclk_i]
set_false_path -from [get_ports spi_mosi_i]
set_false_path -from [get_ports spi_cs_n_i]
set_false_path -to [get_ports spi_miso_o]

set_false_path -from [get_ports sig_clk_i]
set_false_path -from [get_ports sig_sync_i]
set_false_path -to [get_ports gate_sync_o]
