`include "bsg_rocket_pkg.vh"

module bsg_nasti_master_resp
  import bsg_nasti_pkg::*;
  (input                  clk_i
  ,input                  reset_i
  // r in
  ,input                  nasti_r_valid_i
  ,input  bsg_nasti_r_pkt nasti_r_data_i
  ,output                 nasti_r_ready_o
  // resp out
  ,output                 resp_valid_o
  ,output   bsg_tun_dmx_t resp_data_o
  ,input                  resp_yumi_i);

  bsg_nasti_sr_pkt nasti_sr_data;
  bsg_tun_dmx_t    nasti_s_data;

  assign nasti_sr_data.last = nasti_r_data_i.last;
  assign nasti_sr_data.data = nasti_r_data_i.data;
  assign nasti_sr_data.id   = nasti_r_data_i.id;

  assign nasti_s_data = bsg_tun_dmx_t ' (nasti_sr_data);

  bsg_two_fifo #
    (.width_p(bsg_tun_dmx_width_p)) // taken from bsg_rocket_pkg.vh
  fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // r in
    ,.v_i(nasti_r_valid_i)
    ,.data_i(nasti_s_data)
    ,.ready_o(nasti_r_ready_o)
    // resp out
    ,.v_o(resp_valid_o)
    ,.data_o(resp_data_o)
    ,.yumi_i(resp_yumi_i));

endmodule
