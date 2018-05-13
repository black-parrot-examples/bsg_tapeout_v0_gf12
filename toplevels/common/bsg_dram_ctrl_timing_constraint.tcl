
############################################
#
# timing assertions for the bsg DRAM controller
#
# Following constrains might be asserted:
# 
# 1.The async fifo inside the controller
#
# 2.The dqs, dq, delay match
#
# 3.input/output of the dram IOs.
proc bsg_dram_ctrl_timing_constrains {  \
                dram_mc_path            \
                ui_clk_name             \
                dfi_clk_name            \
                dfi_2x_clk_name         \
                dqs_map                 \
                dq0_map                 \
                dq1_map                 \
                dm_map                  \
                ddr_cs_map              \
                ddr_cs_index            \
                ddr_cke_map             \
                ddr_cke_index           \
                ddr_we_map              \
                ddr_we_index            \
                ddr_cas_map             \
                ddr_cas_index           \
                ddr_ras_map             \
                ddr_ras_index           \
                ddr_addr70_map          \
                ddr_addr138_map         \
                ddr_ba_map76            \
} {
}
