`include "bsg_rocket_pkg.vh"
`include "bsg_fsb_pkg.v"

module bsg_rocket_node_master
  import bsg_nasti_pkg::*;
  import bsg_fsb_pkg::*;
# (parameter dest_id_p = 0)
  (input                       clk_i
  ,input                       reset_i
  ,input                       en_i
  // in
  ,input                       v_i
  ,input  bsg_fsb_pkt_client_s data_i
  ,output                      ready_o
  // out
  ,output                      v_o
  ,output bsg_fsb_pkt_client_s data_o
  ,input                       yumi_i
  // host in
  ,input                       host_valid_i
  ,input            bsg_host_t host_data_i
  ,output                      host_ready_o
  // host out
  ,output                      host_valid_o
  ,output           bsg_host_t host_data_o
  ,input                       host_ready_i
  // aw out
  ,output                      nasti_aw_valid_o
  ,output      bsg_nasti_a_pkt nasti_aw_data_o
  ,input                       nasti_aw_ready_i
  // w out
  ,output                      nasti_w_valid_o
  ,output      bsg_nasti_w_pkt nasti_w_data_o
  ,input                       nasti_w_ready_i
  // b in
  ,input                       nasti_b_valid_i
  ,input       bsg_nasti_b_pkt nasti_b_data_i
  ,output                      nasti_b_ready_o
  // ar out
  ,output                      nasti_ar_valid_o
  ,output      bsg_nasti_a_pkt nasti_ar_data_o
  ,input                       nasti_ar_ready_i
  // r in
  ,input                       nasti_r_valid_i
  ,input       bsg_nasti_r_pkt nasti_r_data_i
  ,output                      nasti_r_ready_o);

  wire                 fifo_v;
  bsg_fsb_pkt_client_s fifo_data;
  wire                 fifo_yumi;

  bsg_two_fifo #
    (.width_p($bits(bsg_fsb_pkt_client_s)))
  fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // in valid/ready
    ,.v_i(v_i)
    ,.data_i(data_i)
    ,.ready_o(ready_o)
    // out valid/yumi
    ,.v_o(fifo_v)
    ,.data_o(fifo_data)
    ,.yumi_i(fifo_yumi));

  bsg_fsb_to_rocket f2r
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    // fsb in
    ,.fsb_node_v_i(fifo_v)
    ,.fsb_node_data_i(fifo_data)
    ,.fsb_node_yumi_o(fifo_yumi)
    // fsb out
    ,.fsb_node_v_o(v_o)
    ,.fsb_node_data_o(data_o)
    ,.fsb_node_yumi_i(yumi_i)
    // host in
    ,.host_valid_i(host_valid_i)
    ,.host_data_i(host_data_i)
    ,.host_ready_o(host_ready_o)
    // host out
    ,.host_valid_o(host_valid_o)
    ,.host_data_o(host_data_o)
    ,.host_ready_i(host_ready_i)
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
    // r in
    ,.nasti_r_valid_i(nasti_r_valid_i)
    ,.nasti_r_data_i(nasti_r_data_i)
    ,.nasti_r_ready_o(nasti_r_ready_o));

endmodule
