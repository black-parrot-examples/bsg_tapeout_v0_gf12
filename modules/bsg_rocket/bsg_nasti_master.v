`include "bsg_rocket_pkg.vh"

module bsg_nasti_master
  import bsg_nasti_pkg::*;
  (input                  clk_i
  ,input                  reset_i
  // aw out
  ,output                 nasti_aw_valid_o
  ,output bsg_nasti_a_pkt nasti_aw_data_o
  ,input                  nasti_aw_ready_i
  // w out
  ,output                 nasti_w_valid_o
  ,output bsg_nasti_w_pkt nasti_w_data_o
  ,input                  nasti_w_ready_i
  // b in
  ,input                  nasti_b_valid_i
  ,input  bsg_nasti_b_pkt nasti_b_data_i
  ,output                 nasti_b_ready_o
  // ar out
  ,output                 nasti_ar_valid_o
  ,output bsg_nasti_a_pkt nasti_ar_data_o
  ,input                  nasti_ar_ready_i
  // r in
  ,input                  nasti_r_valid_i
  ,input  bsg_nasti_r_pkt nasti_r_data_i
  ,output                 nasti_r_ready_o
  // req in
  ,input                  req_valid_i
  ,input    bsg_tun_dmx_t req_data_i
  ,output                 req_yumi_o
  // resp out
  ,output                 resp_valid_o
  ,output   bsg_tun_dmx_t resp_data_o
  ,input                  resp_yumi_i);

  bsg_nasti_master_req master_req
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // aw out
    ,.nasti_aw_valid_o(nasti_aw_valid_o)
    ,.nasti_aw_data_o(nasti_aw_data_o)
    ,.nasti_aw_ready_i(nasti_aw_ready_i)
    // w out
    ,.nasti_w_valid_o(nasti_w_valid_o)
    ,.nasti_w_data_o(nasti_w_data_o)
    ,.nasti_w_ready_i(nasti_w_ready_i)
    // b in
    ,.nasti_b_valid_i(nasti_b_valid_i)
    ,.nasti_b_data_i(nasti_b_data_i)
    ,.nasti_b_ready_o(nasti_b_ready_o)
    // ar out
    ,.nasti_ar_valid_o(nasti_ar_valid_o)
    ,.nasti_ar_data_o(nasti_ar_data_o)
    ,.nasti_ar_ready_i(nasti_ar_ready_i)
    // req in
    ,.req_valid_i(req_valid_i)
    ,.req_data_i(req_data_i)
    ,.req_yumi_o(req_yumi_o));

  bsg_nasti_master_resp master_resp
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // r in
    ,.nasti_r_valid_i(nasti_r_valid_i)
    ,.nasti_r_data_i(nasti_r_data_i)
    ,.nasti_r_ready_o(nasti_r_ready_o)
    // resp out
    ,.resp_valid_o(resp_valid_o)
    ,.resp_data_o(resp_data_o)
    ,.resp_yumi_i(resp_yumi_i));

endmodule
